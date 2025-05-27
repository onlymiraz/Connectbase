

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_RunForecastFileImport]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	
	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_RunForecastFileImport
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_RunForecastFileImport]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_RunForecastFileImport
FROM [LOG].[Tracker]

	
	
	EXEC forecast.usp_ImportProjects
	EXEC forecast.usp_ImportSubprojects
	EXEC forecast.usp_ImportGrossAdds 2024

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_RunForecastFileImport P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_RunForecastFileImport



END TRY
BEGIN CATCH
	EXEC usp_error_handler
	RETURN 55555
END CATCH