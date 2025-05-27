
CREATE PROCEDURE [ProjApproval].[InputScreen_SupplementEdit]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__InputScreen_SupplementEdit
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[InputScreen_SupplementEdit]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_FTTH__InputScreen_SupplementEdit
FROM [LOG].[Tracker]

update ProjApproval.PreSale_Compiled set [Supplement Total ISP Capital - Fully Loaded]  =  ProjApproval.InputScreen_SupplementsEdit.[Supplement Total ISP Capital] FROM     ProjApproval.InputScreen_SupplementsEdit INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_SupplementsEdit.[Project Number] = ProjApproval.PreSale_Compiled.[Project Number] AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Total ISP Capital] != '' AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Total ISP Capital] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Supplement Total OSP Capital - Fully Loaded]  =  ProjApproval.InputScreen_SupplementsEdit.[Supplement Total OSP Capital] FROM     ProjApproval.InputScreen_SupplementsEdit INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_SupplementsEdit.[Project Number] = ProjApproval.PreSale_Compiled.[Project Number] AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Total OSP Capital] != '' AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Total OSP Capital] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Supplement Total Capital - Fully Loaded]  =  ProjApproval.InputScreen_SupplementsEdit.[Supplement Total Capital] FROM     ProjApproval.InputScreen_SupplementsEdit INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_SupplementsEdit.[Project Number] = ProjApproval.PreSale_Compiled.[Project Number] AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Total Capital] != '' AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Total Capital] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Supplement Monthly Expense]  =  ProjApproval.InputScreen_SupplementsEdit.[Supplement Monthly Expense] FROM     ProjApproval.InputScreen_SupplementsEdit INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_SupplementsEdit.[Project Number] = ProjApproval.PreSale_Compiled.[Project Number] AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Monthly Expense] != '' AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Monthly Expense] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Supplement NPV - Fully Loaded]  =  ProjApproval.InputScreen_SupplementsEdit.[Supplement NPV] FROM     ProjApproval.InputScreen_SupplementsEdit INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_SupplementsEdit.[Project Number] = ProjApproval.PreSale_Compiled.[Project Number] AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement NPV] != '' AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement NPV] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Supplement IRR - Fully Loaded]  =  ProjApproval.InputScreen_SupplementsEdit.[Supplement IRR] FROM     ProjApproval.InputScreen_SupplementsEdit INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_SupplementsEdit.[Project Number] = ProjApproval.PreSale_Compiled.[Project Number] AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement IRR] != '' AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement IRR] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Supplement Payback - Fully Loaded]  =  ProjApproval.InputScreen_SupplementsEdit.[Supplement Payback] FROM     ProjApproval.InputScreen_SupplementsEdit INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_SupplementsEdit.[Project Number] = ProjApproval.PreSale_Compiled.[Project Number] AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Payback] != '' AND  ProjApproval.InputScreen_SupplementsEdit.[Supplement Payback] IS NOT NULL


delete from ProjApproval.InputScreen_SupplementsEdit


delete from ProjApproval.PreSale_Compiled
FROM     ProjApproval.PreSale_Compiled INNER JOIN
                  ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed ON ProjApproval.PreSale_Compiled.[Opportunity ID] = ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed.OpportunityID
where ProjApproval.PreSale_Compiled.[Project Number] like 'TBD'

Update ProjApproval.PreSale_Compiled
set build = replace(build, '["', '')
Update ProjApproval.PreSale_Compiled
set build = replace(build, '"]', '')

Update ProjApproval.PreSale_Compiled
set [Type of Deal] = replace([Type of Deal], '["', '')
Update ProjApproval.PreSale_Compiled
set [Type of Deal] = replace([Type of Deal], '"]', '')

Update ProjApproval.PreSale_Compiled
set [Brownfield/Greenfield] = replace([Brownfield/Greenfield], '["', '')
Update ProjApproval.PreSale_Compiled
set [Brownfield/Greenfield] = replace([Brownfield/Greenfield], '"]', '')

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_FTTH__InputScreen_SupplementEdit P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__InputScreen_SupplementEdit


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
