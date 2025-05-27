
CREATE PROCEDURE [ProjApproval].[CleanScreens]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__CleanScreens
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[CleanScreens]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_ProjApproval__CleanScreens
FROM [LOG].[Tracker]

delete from ProjApproval.AgendaSetup
where SubmittedBy like '%mmm722%'
delete from ProjApproval.EditScreen_PreSale_Compiled
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_Approval
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_BDT
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_BDT_Trimmed
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_CRC
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_CRC_Trimmed
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_Facilities
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_Facilities_Trimmed
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_Grants
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_Grants_Trimmed
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_MDUSubdivision
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_PreSale_MDUSubdivision_Trimmed
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_Projects_ExistingOpportunity
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
delete from ProjApproval.InputScreen_Supplements
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_Supplements_Trimmed
where SubmittedBy like '%mmm722%'
delete from ProjApproval.InputScreen_SupplementsEdit
where SubmittedBy like '%mmm722%'
delete from ProjApproval.EditScreen_PreSale_Compiled
where SubmittedBy like '%mmm722%'
delete from [ProjApproval].[PreSale_Compiled]
where SubmittedBy like '%mmm722%'


UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_ProjApproval__CleanScreens P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__CleanScreens


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
