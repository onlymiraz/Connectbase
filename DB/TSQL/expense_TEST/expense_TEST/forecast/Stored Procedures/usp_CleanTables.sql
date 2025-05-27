-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_CleanTables]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY

INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
    ('[forecast].[usp_CleanTables]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')
		
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_CleanTables

SELECT MAX(EVENTID) AS LATESTID 
INTO LOG.Tracker_Temp_forecast__usp_CleanTables
FROM LOG.Tracker WHERE EVENTNAME='[forecast].[usp_CleanTables]'

	-- Clean import tables
	TRUNCATE TABLE APPROVED
	--TRUNCATE TABLE AUTHORIZED
	TRUNCATE TABLE BUDGETLINE
	TRUNCATE TABLE CIACFORFF
	TRUNCATE TABLE FFFIELDS
	TRUNCATE TABLE ForecastImport
	TRUNCATE TABLE FUTUREYEAR
	TRUNCATE TABLE GA
	TRUNCATE TABLE NewProjects
	TRUNCATE TABLE SPREAD
	TRUNCATE TABLE VarassetStatus
	TRUNCATE TABLE ESTIMATE


	-- Clean forecast tables
	/*
	DELETE FROM forecast.GrossAddsDirect
	DELETE FROM forecast.GrossAddsIndirect
	DELETE FROM forecast.Note
	DELETE FROM forecast.SubprojectFinancial
	DELETE FROM forecast.Subproject
	DELETE FROM forecast.Project
	*/

	UPDATE T
	SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker T
	INNER JOIN LOG.Tracker_TemP_forecast__usp_CleanTables P
	ON T.EVENTID = P.LATESTID


	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_CleanTables

END TRY
BEGIN CATCH
	EXEC usp_error_handler
	RETURN 55555
END CATCH