-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateSpread]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateSpread
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateSpread]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateSpread
FROM [LOG].[Tracker]



		-- Insert new or update existing budget lines
		MERGE forecast.BudgetLine B
		USING dbo.SPREAD S
		ON B.BudgetLineNumber = S.BudgetLineNumber
		WHEN MATCHED THEN
			UPDATE
			SET B.BudgetLineName = S.BudgetLineName
		WHEN NOT MATCHED THEN
			INSERT (BudgetLineNumber, BudgetLineName)
			VALUES (S.BudgetLineNumber, S.BudgetLineName);

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateSpread P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateSpread



	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH