-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_ImportProjectsFromTable]
	-- Add the parameters for the stored procedure here
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
		DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ImportProjectsFromTable
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_ImportProjectsFromTable]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_ImportProjectsFromTable
FROM [LOG].[Tracker]

		DROP TABLE IF EXISTS #PI
SELECT DISTINCT [ProjectNumber]
      ,[SubprojectNumber]
INTO #PI	  
  FROM [dbo].[ProjectImport]

  TRUNCATE TABLE [dbo].[ProjectImport]

 INSERT INTO [dbo].[ProjectImport]
 ([ProjectNumber]
      ,[SubprojectNumber])
SELECT [ProjectNumber]
      ,[SubprojectNumber]
FROM #PI
DROP TABLE IF EXISTS #PI
		
		
		INSERT forecast.Project (ProjectNumber)
		SELECT DISTINCT ProjectNumber
		FROM dbo.ProjectImport I
		WHERE NOT EXISTS (SELECT ProjectNumber FROM forecast.Project P WHERE P.ProjectNumber = I.ProjectNumber)

		INSERT forecast.Subproject (ProjectNumber, SubprojectNumber)
		SELECT DISTINCT ProjectNumber, SubprojectNumber
		FROM dbo.ProjectImport I
		WHERE NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM forecast.Subproject S WHERE S.ProjectNumber = I.ProjectNumber AND S.SubprojectNumber = I.SubprojectNumber)
	
	
	UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_ImportProjectsFromTable P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ImportProjectsFromTable

	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH