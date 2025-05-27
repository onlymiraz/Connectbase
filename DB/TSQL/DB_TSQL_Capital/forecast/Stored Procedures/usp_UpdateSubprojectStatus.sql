-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateSubprojectStatus]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateSubprojectStatus
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateSubprojectStatus]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateSubprojectStatus
FROM [LOG].[Tracker]



		UPDATE forecast.Subproject
		SET SubprojectStatus = 'Closed'
		WHERE ProjectStatusCode = 'CL'

		UPDATE forecast.Subproject
		SET SubprojectStatus = 'Canceled'
		WHERE ProjectStatusCode = 'CX'
	
		UPDATE forecast.Subproject
		SET SubprojectStatus = 'Re-opened'
		WHERE SubprojectStatus = 'Closed' AND ProjectStatusCode != 'CL'

		UPDATE forecast.Subproject
		SET SubprojectStatus = 'IS Needed'
		WHERE ProjectStatusCode = 'SP'
	
		UPDATE forecast.Subproject
		SET SubprojectStatus = NULL
		WHERE SubprojectStatus = 'IS Needed' AND ProjectStatusCode != 'SP'
	
		UPDATE S
		SET S.SubprojectStatus = NULL
		FROM forecast.Subproject S LEFT JOIN forecast.Project P ON S.ProjectNumber = P.ProjectNumber
		WHERE SubprojectStatus = 'Hold' AND P.ApprovalCode = 'AP'

		UPDATE S
		SET S.SubprojectStatus = NULL
		FROM forecast.Subproject S INNER JOIN forecast.GrossAddsDirect GD ON S.ProjectNumber = GD.ProjectNumber AND S.SubprojectNumber = GD.SubprojectNumber
			 INNER JOIN forecast.GrossAddsIndirect GI ON S.ProjectNumber = GI.ProjectNumber AND S.SubprojectNumber = GI.SubprojectNumber
		WHERE S.ProjectStatusCode = 'Credit Balance' AND S.ProjectStatusCode NOT IN ('CL', 'CX') AND 
			  (GD.January + GD.February + GD.March + GD.April + GD.May + GD.June + GD.July + GD.September + GD.October + GD.November + GD.December +
			   GI.January + GI.February + GI.March + GI.April + GI.May + GI.June + GI.July + GI.September + GI.October + GI.November + GI.December) >= 0

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateSubprojectStatus P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateSubprojectStatus



	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH