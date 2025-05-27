-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateFutureYear]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateFutureYear
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateFutureYear]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateFutureYear
FROM [LOG].[Tracker]


		-- Update Infinium future year spending
		UPDATE S
		SET S.SpendInfinium = ISNULL(ROUND(F.Dollars, 2), 0)
		FROM forecast.SubprojectFutureYear AS S LEFT JOIN (SELECT ProjectNumber, SubprojectNumber, SUM(Dollars) AS Dollars FROM dbo.FUTUREYEAR GROUP BY ProjectNumber, SubprojectNumber) AS F ON S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber
	
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateFutureYear P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateFutureYear
	
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH