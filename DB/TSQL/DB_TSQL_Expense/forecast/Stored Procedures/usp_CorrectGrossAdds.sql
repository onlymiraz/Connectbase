
CREATE PROCEDURE [forecast].[usp_CorrectGrossAdds]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION

DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_CorrectGrossAdds
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_CorrectGrossAdds]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_CorrectGrossAdds
FROM [LOG].[Tracker]






--drop temp tables
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBO].[GD]') AND type in (N'U'))
DROP TABLE [DBO].[GD]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBO].[GI]') AND type in (N'U'))
DROP TABLE [DBO].[GI]




--Direct
SELECT distinct cast(gaprj# as int) as ProjectNumber
      ,cast(gaprjs as smallint) as SubProjectNumber
	  ,cast(GAACTP as smallint) as GAACTP
      ,SUM(cast([GARPT$] as FLOAT)) as [GARPT$]
into dbo.GD
  FROM [history].[GALisa]
  where GAACTY = '2022'
  and left(GAMTRX,1) != '9'
  GROUP BY GAPRJ#,GAPRJS,GAACTP


--Resurrection_Direct
UPDATE FD SET FD.January =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=1
UPDATE FD SET FD.February =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=2
UPDATE FD SET FD.March =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=3
UPDATE FD SET FD.April =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=4
UPDATE FD SET FD.May =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=5
UPDATE FD SET FD.June =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=6
UPDATE FD SET FD.July =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=7
UPDATE FD SET FD.August =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=8
UPDATE FD SET FD.September =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=9
UPDATE FD SET FD.October =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=10
UPDATE FD SET FD.November =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=11
UPDATE FD SET FD.December =0 FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=12






--Update forecast_direct

UPDATE FD SET FD.January =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=1
UPDATE FD SET FD.February =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=2
UPDATE FD SET FD.March =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=3
UPDATE FD SET FD.April =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=4
UPDATE FD SET FD.May =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=5
UPDATE FD SET FD.June =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=6
UPDATE FD SET FD.July =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=7
UPDATE FD SET FD.August =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=8
UPDATE FD SET FD.September =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=9
UPDATE FD SET FD.October =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=10
UPDATE FD SET FD.November =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=11
UPDATE FD SET FD.December =GD.GARPT$ FROM forecast.GrossAddsDirect AS FD, GD WHERE FD.ProjectNumber=GD.ProjectNumber  AND FD.SubprojectNumber=GD.SubProjectNumber AND GD.GAACTP=12



---------------------------------------------------------------------------------------------------
--InDirect
SELECT distinct cast(gaprj# as int) as ProjectNumber
      ,cast(gaprjs as smallint) as SubProjectNumber
	  ,cast(GAACTP as smallint) as GAACTP
      ,SUM(cast([GARPT$] as FLOAT)) as [GARPT$]
into dbo.GI
  FROM [history].[GALisa]
  where GAACTY = '2022'
  and left(GAMTRX,1) = '9'
  GROUP BY GAPRJ#,GAPRJS,GAACTP

--Resurrection_Indirect
UPDATE FI SET FI.January =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=1
UPDATE FI SET FI.February =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=2
UPDATE FI SET FI.March =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=3
UPDATE FI SET FI.April =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=4
UPDATE FI SET FI.May =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=5
UPDATE FI SET FI.June =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=6
UPDATE FI SET FI.July =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=7
UPDATE FI SET FI.August =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=8
UPDATE FI SET FI.September =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=9
UPDATE FI SET FI.October =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=10
UPDATE FI SET FI.November =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=11
UPDATE FI SET FI.December =0 FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=12


--Update forecast_Indirect
UPDATE FI SET FI.January =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=1
UPDATE FI SET FI.February =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=2
UPDATE FI SET FI.March =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=3
UPDATE FI SET FI.April =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=4
UPDATE FI SET FI.May =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=5
UPDATE FI SET FI.June =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=6
UPDATE FI SET FI.July =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=7
UPDATE FI SET FI.August =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=8
UPDATE FI SET FI.September =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=9
UPDATE FI SET FI.October =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=10
UPDATE FI SET FI.November =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=11
UPDATE FI SET FI.December =GI.GARPT$ FROM forecast.GrossAddsInDirect AS FI, GI WHERE FI.ProjectNumber=GI.ProjectNumber  AND FI.SubprojectNumber=GI.SubProjectNumber AND GI.GAACTP=12


--drop temp tables
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBO].[GD]') AND type in (N'U'))
DROP TABLE [DBO].[GD]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBO].[GI]') AND type in (N'U'))
DROP TABLE [DBO].[GI]

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_CorrectGrossAdds P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_CorrectGrossAdds



	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH