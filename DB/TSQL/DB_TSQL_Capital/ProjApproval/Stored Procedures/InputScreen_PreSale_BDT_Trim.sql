
CREATE PROCEDURE [ProjApproval].[InputScreen_PreSale_BDT_Trim]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__InputScreen_PreSale_BDT_Trim
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[InputScreen_PreSale_BDT_Trim]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_ProjApproval__InputScreen_PreSale_BDT_Trim
FROM [LOG].[Tracker]

insert into [ProjApproval].[InputScreen_PreSale_BDT_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[BDT#]
	  ,[Description]
      ,[Budget Category]
      ,[Exchange]
      ,[State]
      ,[Total ISP Capital - Fully Loaded]
      ,[Total OSP Capital - Fully Loaded]
      ,[Total Capital - Fully Loaded]
      ,[MRC - Fully Loaded]
      ,[CIAC - Fully Loaded]
      ,[NPV - Fully Loaded]
      ,[IRR - Fully Loaded]
      ,[Payback - Fully Loaded]
      ,[Total ISP Capital - 20% Loaded]
      ,[Total OSP Capital - 20% Loaded]
      ,[Total Capital - 20% Loaded]
      ,[MRC - 20% Loaded]
      ,[CIAC - 20% Loaded]
      ,[NPV - 20% Loaded]
      ,[IRR - 20% Loaded]
      ,[Payback - 20% Loaded]
      ,[Term in Months]
      ,[Bandwidth (Number of Units)]
      ,[Bandwidth (Unit of Measurement)]
      ,[NRC]
      ,[Monthly Expense]
      ,[Notes]
      ,[Additional Documents])
  select 
  'BDT_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[BDT#]
	  ,[Description]
      ,[Budget Category]
      ,[Exchange]
      ,[State]
      ,[Total ISP Capital - Fully Loaded]
      ,[Total OSP Capital - Fully Loaded]
      ,[Total Capital - Fully Loaded]
      ,[MRC - Fully Loaded]
      ,[CIAC - Fully Loaded]
      ,[NPV - Fully Loaded]
      ,[IRR - Fully Loaded]
      ,[Payback - Fully Loaded]
      ,[Total ISP Capital - 20% Loaded]
      ,[Total OSP Capital - 20% Loaded]
      ,[Total Capital - 20% Loaded]
      ,[MRC - 20% Loaded]
      ,[CIAC - 20% Loaded]
      ,[NPV - 20% Loaded]
      ,[IRR - 20% Loaded]
      ,[Payback - 20% Loaded]
      ,[Term in Months]
      ,[Bandwidth (Number of Units)]
      ,[Bandwidth (Unit of Measurement)]
      ,[NRC]
      ,[Monthly Expense]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_PreSale_BDT]
  WHERE 'BDT_'+[ID] not in
	(
	select
	[Opportunity ID]
	from [ProjApproval].[InputScreen_PreSale_BDT_Trimmed]
	)



insert into ProjApproval.PreSale_Compiled
(
[Opportunity ID]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[CRC Date]
      ,[BDT#]
      ,[Project Description]
      ,[Budget Category]
      ,[Exchange]
      ,[State]
      ,[Total ISP Capital - Fully Loaded]
      ,[Total OSP Capital - Fully Loaded]
      ,[Total Capital - Fully Loaded]
      ,[MRC - Fully Loaded]
      ,[CIAC - Fully Loaded]
      ,[NPV - Fully Loaded]
      ,[IRR - Fully Loaded]
      ,[Payback - Fully Loaded]
      ,[Total ISP Capital - 20% Loaded]
      ,[Total OSP Capital - 20% Loaded]
      ,[Total Capital - 20% Loaded]
      ,[MRC - 20% Loaded]
      ,[CIAC - 20% Loaded]
      ,[NPV - 20% Loaded]
      ,[IRR - 20% Loaded]
      ,[Payback - 20% Loaded]
      ,[Term in Months]
      ,[Bandwidth (Number of Units)]
      ,[Bandwidth (Unit of Measurement)]
      ,[NRC]
      ,[Monthly Expense]
      ,[Notes]
      ,[Additional Documents]
)
SELECT [Opportunity ID]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[CRC Date]
      ,[BDT#]
      ,[Description]
      ,[Budget Category]
      ,[Exchange]
      ,[State]
      ,[Total ISP Capital - Fully Loaded]
      ,[Total OSP Capital - Fully Loaded]
      ,[Total Capital - Fully Loaded]
      ,[MRC - Fully Loaded]
      ,[CIAC - Fully Loaded]
      ,[NPV - Fully Loaded]
      ,[IRR - Fully Loaded]
      ,[Payback - Fully Loaded]
      ,[Total ISP Capital - 20% Loaded]
      ,[Total OSP Capital - 20% Loaded]
      ,[Total Capital - 20% Loaded]
      ,[MRC - 20% Loaded]
      ,[CIAC - 20% Loaded]
      ,[NPV - 20% Loaded]
      ,[IRR - 20% Loaded]
      ,[Payback - 20% Loaded]
      ,[Term in Months]
      ,[Bandwidth (Number of Units)]
      ,[Bandwidth (Unit of Measurement)]
      ,[NRC]
      ,[Monthly Expense]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_PreSale_BDT_Trimmed]
where ProjApproval.[InputScreen_PreSale_BDT_Trimmed].[Opportunity ID]
NOT IN (
select [Opportunity ID] from ProjApproval.PreSale_Compiled
)

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

--delete from ProjApproval.PreSale_Compiled
--FROM     ProjApproval.PreSale_Compiled INNER JOIN
--                  ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed ON ProjApproval.PreSale_Compiled.[Opportunity ID] = ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed.OpportunityID
--where ProjApproval.PreSale_Compiled.[Project Number] like 'TBD'

delete from ProjApproval.InputScreen_PreSale_BDT
delete from ProjApproval.InputScreen_PreSale_BDT_Trimmed

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_ProjApproval__InputScreen_PreSale_BDT_Trim P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__InputScreen_PreSale_BDT_Trim

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
