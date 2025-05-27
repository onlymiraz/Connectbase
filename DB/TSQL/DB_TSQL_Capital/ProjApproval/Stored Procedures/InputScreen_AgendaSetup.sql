
CREATE PROCEDURE [ProjApproval].[InputScreen_AgendaSetup]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__InputScreen_AgendaSetup
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[InputScreen_AgendaSetup]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_ProjApproval__InputScreen_AgendaSetup
FROM [LOG].[Tracker]

update ProjApproval.PreSale_Compiled set [Presenter First Name]  =  ProjApproval.AgendaSetup.[Presenter First Name] FROM     ProjApproval.PreSale_Compiled INNER JOIN
                  ProjApproval.AgendaSetup ON ProjApproval.PreSale_Compiled.[Opportunity ID] = ProjApproval.AgendaSetup.[Opportunity ID] AND  ProjApproval.AgendaSetup.[Presenter First Name] != '' AND  ProjApproval.AgendaSetup.[Presenter First Name] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Presenter Last Name]  =  ProjApproval.AgendaSetup.[Presenter Last Name] FROM     ProjApproval.PreSale_Compiled INNER JOIN
                  ProjApproval.AgendaSetup ON ProjApproval.PreSale_Compiled.[Opportunity ID] = ProjApproval.AgendaSetup.[Opportunity ID] AND  ProjApproval.AgendaSetup.[Presenter Last Name] != '' AND  ProjApproval.AgendaSetup.[Presenter Last Name] IS NOT NULL
update ProjApproval.PreSale_Compiled set [Agenda#]  =  ProjApproval.AgendaSetup.[Agenda#] FROM     ProjApproval.PreSale_Compiled INNER JOIN
                  ProjApproval.AgendaSetup ON ProjApproval.PreSale_Compiled.[Opportunity ID] = ProjApproval.AgendaSetup.[Opportunity ID] AND  ProjApproval.AgendaSetup.[Agenda#] != '' AND  ProjApproval.AgendaSetup.[Agenda#] IS NOT NULL



delete from ProjApproval.AgendaSetup

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
INNER JOIN LOG.Tracker_Temp_ProjApproval__InputScreen_AgendaSetup P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__InputScreen_AgendaSetup

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
