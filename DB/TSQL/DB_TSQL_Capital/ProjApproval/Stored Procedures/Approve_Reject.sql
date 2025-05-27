
CREATE PROCEDURE [ProjApproval].[Approve_Reject]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__Approve_Reject
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[Approve_Reject]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_ProjApproval__Approve_Reject
FROM [LOG].[Tracker]

update ProjApproval.PreSale_Compiled set [CRC Date Submitted]  =  ProjApproval.InputScreen_Approval.[CRC Date Submitted] FROM     ProjApproval.InputScreen_Approval INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_Approval.[Opportunity ID] = ProjApproval.PreSale_Compiled.[Opportunity ID] AND  ProjApproval.InputScreen_Approval.[CRC Date Submitted] != '' AND  ProjApproval.InputScreen_Approval.[CRC Date Submitted] IS NOT NULL
update ProjApproval.PreSale_Compiled set [VP Cap Mgt Approved Date]  =  ProjApproval.InputScreen_Approval.[VP Cap Mgt Approval Date] FROM     ProjApproval.InputScreen_Approval INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_Approval.[Opportunity ID] = ProjApproval.PreSale_Compiled.[Opportunity ID] AND  ProjApproval.InputScreen_Approval.[VP Cap Mgt Approval Date] != '' AND  ProjApproval.InputScreen_Approval.[VP Cap Mgt Approval Date] IS NOT NULL
update ProjApproval.PreSale_Compiled set [SVP Tech Fin Approval Date]  =  ProjApproval.InputScreen_Approval.[SVP Tech Fin Approval Date] FROM     ProjApproval.InputScreen_Approval INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_Approval.[Opportunity ID] = ProjApproval.PreSale_Compiled.[Opportunity ID] AND  ProjApproval.InputScreen_Approval.[SVP Tech Fin Approval Date] != '' AND  ProjApproval.InputScreen_Approval.[SVP Tech Fin Approval Date] IS NOT NULL
update ProjApproval.PreSale_Compiled set [ELT Date Submitted]  =  ProjApproval.InputScreen_Approval.[ELT Date Submitted] FROM     ProjApproval.InputScreen_Approval INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_Approval.[Opportunity ID] = ProjApproval.PreSale_Compiled.[Opportunity ID] AND  ProjApproval.InputScreen_Approval.[ELT Date Submitted] != '' AND  ProjApproval.InputScreen_Approval.[ELT Date Submitted] IS NOT NULL
update ProjApproval.PreSale_Compiled set [ELT Approval Date]  =  ProjApproval.InputScreen_Approval.[ELT Approval Date] FROM     ProjApproval.InputScreen_Approval INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_Approval.[Opportunity ID] = ProjApproval.PreSale_Compiled.[Opportunity ID] AND  ProjApproval.InputScreen_Approval.[ELT Approval Date] != '' AND  ProjApproval.InputScreen_Approval.[ELT Approval Date] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Final Approval Date]  =  ProjApproval.InputScreen_Approval.[Final Approval Date] FROM     ProjApproval.InputScreen_Approval INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_Approval.[Opportunity ID] = ProjApproval.PreSale_Compiled.[Opportunity ID] AND  ProjApproval.InputScreen_Approval.[Final Approval Date] != '' AND  ProjApproval.InputScreen_Approval.[Final Approval Date] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Approval Notes]  =  ProjApproval.InputScreen_Approval.[Approval Notes] FROM     ProjApproval.InputScreen_Approval INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_Approval.[Opportunity ID] = ProjApproval.PreSale_Compiled.[Opportunity ID] AND  ProjApproval.InputScreen_Approval.[Approval Notes] != '' AND  ProjApproval.InputScreen_Approval.[Approval Notes] IS NOT NULL





TRUNCATE TABLE ProjApproval.InputScreen_Approval


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
INNER JOIN LOG.Tracker_Temp_ProjApproval__Approve_Reject P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__Approve_Reject


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
