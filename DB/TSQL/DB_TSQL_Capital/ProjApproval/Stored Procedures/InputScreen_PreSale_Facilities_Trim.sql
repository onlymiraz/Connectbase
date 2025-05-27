
CREATE PROCEDURE [ProjApproval].[InputScreen_PreSale_Facilities_Trim]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__InputScreen_PreSale_Facilities_Trim
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[InputScreen_PreSale_Facilities_Trim]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_ProjApproval__InputScreen_PreSale_Facilities_Trim
FROM [LOG].[Tracker]


insert into ProjApproval.InputScreen_PreSale_Facilities_Trimmed
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Street Address]
      ,[City]
      ,[State]
      ,[ZIP Code]
      ,[Project Number]
      ,[Project Description]
      ,[Total Capital Cost]
      ,[Capital Request]
      ,[Capital Request Q1]
      ,[Capital Request Q2]
      ,[Capital Request Q3]
      ,[Capital Request Q4]
      ,[Capital Cost Future Years]
      ,[Link Code]
      ,[Additional Documents])
  select
  'Facilities_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Street Address]
      ,[City]
      ,[State]
      ,[ZIP Code]
      ,[Project Number]
      ,[Project Description]
      ,[Total Capital Cost]
      ,[Capital Request]
      ,[Capital Request Q1]
      ,[Capital Request Q2]
      ,[Capital Request Q3]
      ,[Capital Request Q4]
      ,[Capital Cost Future Years]
      ,[Link Code]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_PreSale_Facilities]
   WHERE 'Facilities_'+[ID] not in
	(
	select
	[Opportunity ID]
	from [ProjApproval].[InputScreen_PreSale_Facilities_Trimmed]
	)

INSERT INTO [ProjApproval].[PreSale_Compiled]
           (
[Opportunity ID],
[Project Number],
[Project Description],
[SubmitttedDtm],
[SubmittedBy],
[CRC Date],
[Budget Category],
[State],
[Capital Request],
[Capital Request Q1],
[Capital Request Q2],
[Capital Request Q3],
[Capital Request Q4],
[Capital Cost Future Years],
[Street Address],
[City],
[ZIP Code],
[Link Code],
[Additional Documents]
)
select
[Opportunity ID],
[Project Number],
[Project Description],
[SubmitttedDtm],
[SubmittedBy],
[CRC Date],
[Budget Category],
[State],
[Capital Request],
[Capital Request Q1],
[Capital Request Q2],
[Capital Request Q3],
[Capital Request Q4],
[Capital Cost Future Years],
[Street Address],
[City],
[ZIP Code],
[Link Code],
[Additional Documents]
from ProjApproval.[InputScreen_PreSale_Facilities_Trimmed]
where ProjApproval.[InputScreen_PreSale_Facilities_Trimmed].[Opportunity ID]
NOT IN (
select [Opportunity ID] from ProjApproval.PreSale_Compiled
)

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


delete from ProjApproval.InputScreen_PreSale_Facilities
delete from ProjApproval.InputScreen_PreSale_Facilities_Trimmed
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_ProjApproval__InputScreen_PreSale_Facilities_Trim P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__InputScreen_PreSale_Facilities_Trim

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH

