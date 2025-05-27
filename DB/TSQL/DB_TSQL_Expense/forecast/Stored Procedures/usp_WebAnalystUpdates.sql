
CREATE PROCEDURE [forecast].[usp_WebAnalystUpdates]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_WebAnalystUpdates
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_WebAnalystUpdates]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_WebAnalystUpdates
FROM [LOG].[Tracker]

----------------------------------------------------------------------------------
update webapp.MSFormsAnalystUpdates
set [Spending Not Needed] = 0 where [Spending Not Needed] is null
update webapp.MSFormsAnalystUpdates
set [Future Spending] = 0 where [Future Spending] is null

----------------------------------------------------------------------------------------------------------
--Both subs selected
update webapp.MSFormsAnalystUpdates
set [Project Sub Number(s)] = 0 where [Project Sub Number(s)] like '%Both%'

--sub 1
DECLARE @S1 table (
	[ID] [varchar](50) NULL,
	[SubmittedBy] [varchar](50) NULL,
	[SubmitttedDtm] [varchar](50) NULL,
	[Username (Frontier CORP ID)] [varchar](50) NULL,
	[Project Number] [varchar](50) NULL,
	[Project Sub Number(s)] [varchar](50) NULL,
	[Spending Not Needed] [varchar](50) NULL,
	[Future Spending] [varchar](50) NULL,
	[Current Project Status] [varchar](50) NULL,
	[Analyst Notes] [varchar](max) NULL)

INSERT INTO @S1 ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM webapp.MSFormsAnalystUpdates
where [Project Sub Number(s)] = 0 or [Project Sub Number(s)] like '%Both%'

UPDATE @S1 SET [Project Sub Number(s)] = 1

--sub 4
DECLARE @S4 table (
	[ID] [varchar](50) NULL,
	[SubmittedBy] [varchar](50) NULL,
	[SubmitttedDtm] [varchar](50) NULL,
	[Username (Frontier CORP ID)] [varchar](50) NULL,
	[Project Number] [varchar](50) NULL,
	[Project Sub Number(s)] [varchar](50) NULL,
	[Spending Not Needed] [varchar](50) NULL,
	[Future Spending] [varchar](50) NULL,
	[Current Project Status] [varchar](50) NULL,
	[Analyst Notes] [varchar](max) NULL)

INSERT INTO @S4 ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM @S1

UPDATE @S4 SET [Project Sub Number(s)] = 4

--Bring back to original web table
DECLARE @S table (
	[ID] [varchar](50) NULL,
	[SubmittedBy] [varchar](50) NULL,
	[SubmitttedDtm] [varchar](50) NULL,
	[Username (Frontier CORP ID)] [varchar](50) NULL,
	[Project Number] [varchar](50) NULL,
	[Project Sub Number(s)] [varchar](50) NULL,
	[Spending Not Needed] [varchar](50) NULL,
	[Future Spending] [varchar](50) NULL,
	[Current Project Status] [varchar](50) NULL,
	[Analyst Notes] [varchar](max) NULL)

--SUB 1
INSERT INTO @S ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM @S1

--SUB 4
INSERT INTO @S ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM @S4

--FINALIZE
INSERT INTO [webapp].[MSFormsAnalystUpdates] ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT DISTINCT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM @S

--CLEAN 
DELETE FROM [webapp].[MSFormsAnalystUpdates] WHERE [Project Sub Number(s)]=0

----------------------------------------------------------------------------------------------------------%'

UPDATE forecast.Subproject
SET forecast.Subproject.SubprojectStatus = webapp.MSFormsAnalystUpdates.[Current Project Status]
from forecast.Subproject
inner join webapp.MSFormsAnalystUpdates
on forecast.subproject.ProjectNumber = webapp.MSFormsAnalystUpdates.[Project Number] 
--AND forecast.subproject.SubprojectNumber = webapp.MSFormsAnalystUpdates.[Project Sub Number(s)];

UPDATE forecast.SubprojectFinancial
SET forecast.SubprojectFinancial.SpendingNotNeeded = cast(webapp.MSFormsAnalystUpdates.[Spending Not Needed] as money)
from forecast.SubprojectFinancial
inner join webapp.MSFormsAnalystUpdates
on  forecast.SubprojectFinancial.ProjectNumber = webapp.MSFormsAnalystUpdates.[Project Number] 
AND forecast.SubprojectFinancial.SubprojectNumber = webapp.MSFormsAnalystUpdates.[Project Sub Number(s)];

UPDATE forecast.SubprojectFutureYear
SET forecast.SubprojectFutureYear.Spend = cast(webapp.MSFormsAnalystUpdates.[Future Spending] as money)
from forecast.SubprojectFutureYear
inner join webapp.MSFormsAnalystUpdates
on forecast.SubprojectFutureYear.ProjectNumber = webapp.MSFormsAnalystUpdates.[Project Number] 
AND forecast.SubprojectFutureYear.SubprojectNumber = webapp.MSFormsAnalystUpdates.[Project Sub Number(s)];



update webapp.MSFormsAnalystUpdates
set [Analyst Notes] = cast(cast(SubmitttedDtm as date) as nvarchar(10))+'-'+left(SubmittedBy,6)+'-'+[Analyst Notes]
where ID is not null


--Add previous notes
update M
set M.[Analyst Notes]=M.[Analyst Notes]+' '+D.[Analyst Notes]
from webapp.MSFormsAnalystUpdates M,
webapp.MSFormsAnalystUpdatesLatestDetails D
where M.[Project Number]=D.[Project Number]
--and M.[Sub #]=D.[Project Sub Number(s)]
and M.[Analyst Notes]!=D.[Analyst Notes]




	insert into history.note
	(ProjectNumber, SubprojectNumber, [text], CreatedBy, CreatedDate)
	select [Project Number],[Project Sub Number(s)], [Analyst Notes], [SubmittedBy],[SubmitttedDtm]
	from webapp.MSFormsAnalystUpdates
	where [Analyst Notes] is not null


	truncate table [forecast].[notefinal] 
	insert into forecast.NoteFinal 
	( [ProjectNumber], [SubProjectnumber], [Note], [createdby], [createddate] ) 
	SELECT distinct
      [ProjectNumber], [SubprojectNumber], [Text], [CreatedBy], max([CreatedDate]) 
    FROM [history].[note] 
    where [history].[note].[Text] is not null
	group by
        [ProjectNumber],
        [SubprojectNumber],
        [Text],
        [CreatedBy] 
	
    UPDATE forecast.ForecastExport 
    SET AnalystNotes = forecast.NoteFinal.note 
    from forecast.ForecastExport 
    inner join forecast.NoteFinal on 
	[forecast].[NoteFinal].[ProjectNumber] = forecast.ForecastExport.[ProjectNumber]       
	--and [forecast].[NoteFinal].[SubProjectnumber] = forecast.ForecastExport.[SubprojectNumber]






--Correct AnalystNote
INSERT into webapp.MSFormsAnalystUpdatesHistory 
select * from webapp.MSFormsAnalystUpdates	

TRUNCATE TABLE webapp.MSFormsAnalystUpdates


drop table [webapp].[MSFormsAnalystUpdatesLatest]
SELECT [Project Number], [Project Sub Number(s)], max(cast(SubmitttedDtm as datetime)) as LatestDateTime
into [webapp].[MSFormsAnalystUpdatesLatest]
  FROM [webapp].[MSFormsAnalystUpdatesHistory]
where [Project Number] is not null
and [Project Number] != 0
and [Project Sub Number(s)] is not null
and [Project Sub Number(s)] != 0
group by [Project Number], [Project Sub Number(s)]

DROP TABLE webapp.MSFormsAnalystUpdatesLatestDetails
SELECT distinct webapp.MSFormsAnalystUpdatesLatest.[Project Number], webapp.MSFormsAnalystUpdatesLatest.[Project Sub Number(s)], webapp.MSFormsAnalystUpdatesLatest.LatestDateTime, webapp.MSFormsAnalystUpdatesHistory.ID, 
                  webapp.MSFormsAnalystUpdatesHistory.SubmittedBy, webapp.MSFormsAnalystUpdatesHistory.[Username (Frontier CORP ID)], webapp.MSFormsAnalystUpdatesHistory.[Spending Not Needed], 
                  webapp.MSFormsAnalystUpdatesHistory.[Future Spending], webapp.MSFormsAnalystUpdatesHistory.[Current Project Status], webapp.MSFormsAnalystUpdatesHistory.[Analyst Notes]
INTO webapp.MSFormsAnalystUpdatesLatestDetails
FROM     webapp.MSFormsAnalystUpdatesLatest INNER JOIN
                  webapp.MSFormsAnalystUpdatesHistory ON webapp.MSFormsAnalystUpdatesLatest.[Project Number] = webapp.MSFormsAnalystUpdatesHistory.[Project Number] AND 
                  webapp.MSFormsAnalystUpdatesLatest.[Project Sub Number(s)] = webapp.MSFormsAnalystUpdatesHistory.[Project Sub Number(s)] AND 
                  webapp.MSFormsAnalystUpdatesLatest.LatestDateTime = webapp.MSFormsAnalystUpdatesHistory.SubmitttedDtm


update forecast.ForecastExport
set AnalystNotes = webapp.MSFormsAnalystUpdatesLatestDetails.[Analyst Notes]
FROM     forecast.ForecastExport INNER JOIN
                  webapp.MSFormsAnalystUpdatesLatestDetails ON forecast.ForecastExport.ProjectNumber = webapp.MSFormsAnalystUpdatesLatestDetails.[Project Number] 
				  --AND forecast.ForecastExport.SubprojectNumber = webapp.MSFormsAnalystUpdatesLatestDetails.[Project Sub Number(s)]
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_WebAnalystUpdates P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_WebAnalystUpdates


----------------------------------------------------------------------------------

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH