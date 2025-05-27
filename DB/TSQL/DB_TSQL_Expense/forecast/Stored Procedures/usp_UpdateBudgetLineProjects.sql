-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateBudgetLineProjects]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateBudgetLineProjects
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateBudgetLineProjects]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateBudgetLineProjects
FROM [LOG].[Tracker]


		-- Insert projects that are linked to current year budget lines
		INSERT forecast.Project (ProjectNumber)
		SELECT DISTINCT ProjectNumber
		FROM dbo.BUDGETLINE B
		WHERE NOT EXISTS (SELECT ProjectNumber FROM forecast.Project P WHERE P.ProjectNumber = B.ProjectNumber)

		INSERT forecast.Subproject (ProjectNumber, SubprojectNumber)
		SELECT DISTINCT ProjectNumber, SubprojectNumber
		FROM dbo.BUDGETLINE B
		WHERE NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM forecast.Subproject S WHERE S.ProjectNumber = B.ProjectNumber AND S.SubprojectNumber = B.SubprojectNumber)

		INSERT dbo.NewProjects (ProjectNumber, SubprojectNumber)
		SELECT DISTINCT ProjectNumber, SubprojectNumber
		FROM dbo.BUDGETLINE B
		WHERE NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM forecast.Subproject S WHERE S.ProjectNumber = B.ProjectNumber AND S.SubprojectNumber = B.SubprojectNumber)
			AND NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM dbo.NewProjects N WHERE B.ProjectNumber = N.ProjectNumber AND B.SubprojectNumber = N.SubprojectNumber)

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateBudgetLineProjects P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateBudgetLineProjects


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH