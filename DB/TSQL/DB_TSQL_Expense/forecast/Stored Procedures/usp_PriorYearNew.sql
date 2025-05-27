CREATE procedure [forecast].[usp_PriorYearNew]
as
	set xact_abort, nocount on
begin try
begin transaction

DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_PriorYearNew
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_PriorYearNew]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_PriorYearNew
FROM [LOG].[Tracker]




--First week of January, change "!= Current Year"
--embed the above codes into a store proc that will be run once after transitioning to the new year, followed by commenting out for the rest of the year



--step 1 - distinct list all projects from history table, sub 1/4, != Current Year, return total amount and put them in a temp table

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'forecast.SubprojectPriorYear2') AND type in (N'U'))
DROP TABLE forecast.SubprojectPriorYear2

CREATE TABLE [forecast].[SubprojectPriorYear2](
	[GAPRJ#] [varchar](25) NULL,
	[GAPRJS] [varchar](25) NULL,
	[GAMTRX] [varchar](25) NULL,
	[GALDSC] [varchar](255) NULL,
	[Spend] [float] NULL,
	[Direct] [float] NULL,
	[Indirect] [float] NULL
)

insert into forecast.SubprojectPriorYear2
([GAPRJ#]
      ,[GAPRJS]
      ,[GAMTRX]
      ,[GALDSC]
      ,[Spend])
SELECT distinct GAPRJ#, GAPRJS, GAMTRX, GALDSC, sum(cast(GARPT$ as float)) as Spend
  FROM [history].[GALisa]
  where (GAPRJS = '1' or GAPRJS = '4')
  and GAACTY != '2022'
  group by GAPRJ#, GAPRJS, GAMTRX, GALDSC



-- Step 2 - Slit temp table spend into direct
update forecast.SubprojectPriorYear2
set Direct = spend
WHERE left(GAMTRX,1) != '9'


-- Step 3 - Slit temp table spend into Indirect
update forecast.SubprojectPriorYear2
set indirect = spend
where left(GAMTRX,1) = '9'


--STEP 4 - Benefits Load
update forecast.SubprojectPriorYear2
set Direct = spend, Indirect = 0
where GAMTRX = '997'
or (GAMTRX='999' and (GALDSC like '%BENE%' OR GALDSC like '%bene%' or GALDSC like '%Bene%'))


--Step 5 - Summarize temp table to reflect destination
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'forecast.SubprojectPriorYear3') AND type in (N'U'))
DROP TABLE forecast.SubprojectPriorYear3

select distinct cast([GAPRJ#] as int) as ProjectNumber
      ,cast([GAPRJS] as smallint) as Subprojectnumber
      ,sum(cast([Spend] as money)) as Spend
      ,sum(cast([Direct] as money)) as Direct
      ,sum(cast([Indirect] as money)) as Indirect
into forecast.SubprojectPriorYear3
from forecast.SubprojectPriorYear2
group by [GAPRJ#]
      ,[GAPRJS]

update forecast.SubprojectPriorYear3 set Spend = 0 where spend is null
update forecast.SubprojectPriorYear3 set direct = 0 where direct is null
update forecast.SubprojectPriorYear3 set Indirect = 0 where Indirect is null



--drop temps
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'forecast.SubprojectPriorYear2') AND type in (N'U'))
DROP TABLE forecast.SubprojectPriorYear2

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_PriorYearNew P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_PriorYearNew


commit transaction
end try
begin catch
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
end catch