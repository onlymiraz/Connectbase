-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateMisc]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateMisc
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateMisc]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateMisc
FROM [LOG].[Tracker]



		-- Update future years spending on closed projects
		UPDATE F
		SET F.SpendInfinium = 0,
			F.Spend = 0
		FROM forecast.SubprojectFutureYear AS F INNER JOIN forecast.Subproject AS S ON F.ProjectNumber = S.ProjectNumber AND F.SubprojectNumber = S.SubprojectNumber
			 LEFT JOIN forecast.ProjectStatusCode AS PSC ON S.ProjectStatusCodeID = PSC.ID
		WHERE PSC.ProjectStatusCode = 'CL' AND (F.SpendInfinium != 0 OR F.Spend != 0)

		-- Delete projects that are closed or canceled with no gross adds this year
	--	DELETE FROM forecast.ForecastExport WHERE [Proj/Sub Number] IN
	--	(SELECT (D.ProjectNumber + D.SubprojectNumber) AS ProjSub
	--	FROM forecast.GrossAddsDirect AS D INNER JOIN forecast.GrossAddsIndirect AS I ON D.ProjectNumber = I.ProjectNumber AND D.SubprojectNumber = I.SubprojectNumber AND D.[Year] = I.[Year] INNER JOIN forecast.Subproject AS S ON D.ProjectNumber = S.ProjectNumber AND D.SubprojectNumber = S.SubprojectNumber
	--	WHERE D.January = 0 AND I.January = 0
	--	  AND D.February = 0 AND I.February = 0
	--	  AND D.March = 0 AND I.March = 0
	--	  AND D.April = 0 AND I.April = 0
	--	  AND D.May = 0 AND I.May = 0
	--	  AND D.June = 0 AND I.June = 0
	--	  AND D.July = 0 AND I.July = 0
	--	  AND D.August = 0 AND I.August = 0
	--	  AND D.September = 0 AND I.September = 0
	--	  AND D.October = 0 AND I.October = 0
	--	  AND D.November = 0 AND I.November = 0
	--	  AND D.December = 0 AND I.December = 0
	--	  AND S.ProjectStatusCode IN ('CL', 'CX'))

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateMisc P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateMisc


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH