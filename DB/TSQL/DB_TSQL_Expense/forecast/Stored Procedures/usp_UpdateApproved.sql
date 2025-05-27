-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateApproved]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateApproved
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateApproved]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateApproved
FROM [LOG].[Tracker]



		INSERT forecast.Project (ProjectNumber)
		SELECT DISTINCT ProjectNumber
		FROM dbo.APPROVED A
		WHERE NOT EXISTS (SELECT ProjectNumber FROM forecast.Project P WHERE P.ProjectNumber = A.ProjectNumber)
		
		INSERT forecast.Subproject (ProjectNumber, SubprojectNumber)
		SELECT DISTINCT ProjectNumber, SubprojectNumber
		FROM dbo.APPROVED A
		WHERE NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM forecast.Subproject S WHERE S.ProjectNumber = A.ProjectNumber AND S.SubprojectNumber = A.SubprojectNumber)

		INSERT dbo.NewProjects (ProjectNumber, SubprojectNumber)
		SELECT DISTINCT ProjectNumber, SubprojectNumber
		FROM dbo.APPROVED A
		WHERE NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM forecast.Subproject S WHERE S.ProjectNumber = A.ProjectNumber AND S.SubprojectNumber = A.SubprojectNumber)
			AND NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM dbo.NewProjects N WHERE A.ProjectNumber = N.ProjectNumber AND A.SubprojectNumber = N.SubprojectNumber)

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateApproved P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateApproved



	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH