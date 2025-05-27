
CREATE PROCEDURE [forecast].[usp_GA_PythonCorrection]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION

DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_GA_PythonCorrection
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_GA_PythonCorrection]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_GA_PythonCorrection
FROM [LOG].[Tracker]

--clear dbo.GA
truncate table GA


--return all records from txt file
INSERT INTO GA ([ProjectNumber]
      ,[SubprojectNumber]
      ,[GAMTRX]
      ,[GARPT$]
      ,[GAACTY]
      ,[GAACTP])
SELECT cast(GAPRJ# as int)
      ,cast(GAPRJS as smallint)
      ,cast([GAMTRX] as smallint)
      ,cast([GARPT$] as float)
      ,cast([GAACTY] as smallint)
      ,cast([GAACTP] as tinyint)
FROM webapp.ga


UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_GA_PythonCorrection P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_GA_PythonCorrection


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH