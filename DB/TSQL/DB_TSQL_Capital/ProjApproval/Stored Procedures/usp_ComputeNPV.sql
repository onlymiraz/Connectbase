

CREATE PROCEDURE [ProjApproval].[usp_ComputeNPV]

AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__usp_ComputeNPV
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[usp_ComputeNPV]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_FTTH__usp_ComputeNPV
FROM [LOG].[Tracker]

		exec projapproval.usp_Compute_PostSale_BDT
		exec ProjApproval.usp_Compute_PreSale_BDT
		exec ProjApproval.usp_Compute_PostSale_MDUSFU
		--exec [FTTH].[usp_BulkUsageEntrySubmit]
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_FTTH__usp_ComputeNPV P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__usp_ComputeNPV


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
