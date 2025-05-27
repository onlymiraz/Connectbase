
CREATE PROCEDURE [ProjApproval].[InputScreen_Supplement_Trim]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__InputScreen_InputScreen_Supplement_Trim
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[InputScreen_Supplement_Trim]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_ProjApproval__InputScreen_InputScreen_Supplement_Trim
FROM [LOG].[Tracker]


insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 1]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
--      where [Project Number 1] != ''
--and  [Project Number 1] != ' '
--and  [Project Number 1] is not null
--and [ProjApproval].[InputScreen_Supplements].[Project Number 1] NOT IN
--(select [Project Number]
--from [ProjApproval].[InputScreen_Supplements_Trimmed]
--)

insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 2]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
      where [Project Number 2] != ''
and  [Project Number 2] != ' '
and  [Project Number 2] is not null
and [ProjApproval].[InputScreen_Supplements].[Project Number 2] NOT IN
(select [Project Number]
from [ProjApproval].[InputScreen_Supplements_Trimmed]
)


insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 3]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
      where [Project Number 3] != ''
and  [Project Number 3] != ' '
and  [Project Number 3] is not null
and [ProjApproval].[InputScreen_Supplements].[Project Number 3] NOT IN
(select [Project Number]
from [ProjApproval].[InputScreen_Supplements_Trimmed]
)


insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 4]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
      where [Project Number 4] != ''
and  [Project Number 4] != ' '
and  [Project Number 4] is not null
and [ProjApproval].[InputScreen_Supplements].[Project Number 4] NOT IN
(select [Project Number]
from [ProjApproval].[InputScreen_Supplements_Trimmed]
)


insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 5]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
      where [Project Number 5] != ''
and  [Project Number 5] != ' '
and  [Project Number 5] is not null
and [ProjApproval].[InputScreen_Supplements].[Project Number 5] NOT IN
(select [Project Number]
from [ProjApproval].[InputScreen_Supplements_Trimmed]
)


insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 6]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
      where [Project Number 6] != ''
and  [Project Number 6] != ' '
and  [Project Number 6] is not null
and [ProjApproval].[InputScreen_Supplements].[Project Number 6] NOT IN
(select [Project Number]
from [ProjApproval].[InputScreen_Supplements_Trimmed]
)


insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 7]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
      where [Project Number 7] != ''
and  [Project Number 7] != ' '
and  [Project Number 7] is not null
and [ProjApproval].[InputScreen_Supplements].[Project Number 7] NOT IN
(select [Project Number]
from [ProjApproval].[InputScreen_Supplements_Trimmed]
)


insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 8]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
      where [Project Number 8] != ''
and  [Project Number 8] != ' '
and  [Project Number 8] is not null
and [ProjApproval].[InputScreen_Supplements].[Project Number 8] NOT IN
(select [Project Number]
from [ProjApproval].[InputScreen_Supplements_Trimmed]
)


insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 9]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
      where [Project Number 9] != ''
and  [Project Number 9] != ' '
and  [Project Number 9] is not null
and [ProjApproval].[InputScreen_Supplements].[Project Number 9] NOT IN
(select [Project Number]
from [ProjApproval].[InputScreen_Supplements_Trimmed]
)


insert into [ProjApproval].[InputScreen_Supplements_Trimmed]
([Opportunity ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents])
select 
'Supplement_'+[ID]
      ,[Start time]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[Name]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number 10]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements]
      where [Project Number 10] != ''
and  [Project Number 10] != ' '
and  [Project Number 10] is not null
and [ProjApproval].[InputScreen_Supplements].[Project Number 10] NOT IN
(select [Project Number]
from [ProjApproval].[InputScreen_Supplements_Trimmed]
)


insert into ProjApproval.PreSale_Compiled
(
[Opportunity ID]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Supplement Total ISP Capital - Fully Loaded]
      ,[Supplement Total OSP Capital - Fully Loaded]
      ,[Supplement Total Capital - Fully Loaded]
      ,[Supplement Monthly Expense]
      ,[Supplement NPV - Fully Loaded]
      ,[Supplement IRR - Fully Loaded]
      ,[Supplement Payback - Fully Loaded]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
)
SELECT [Opportunity ID]
      ,[SubmitttedDtm]
      ,[SubmittedBy]
      ,[CRC Date]
      ,[Budget Category]
      ,[Link Code]
      ,[Project Description]
      ,[Project Number]
      ,[Total ISP Capital]
      ,[Total OSP Capital]
      ,[Total Capital]
      ,[Monthly Expense]
      ,[NPV]
      ,[IRR]
      ,[Payback]
      ,[State]
      ,[Exchange]
      ,[Notes]
      ,[Additional Documents]
  FROM [ProjApproval].[InputScreen_Supplements_Trimmed]
where ProjApproval.[InputScreen_Supplements_Trimmed].[Opportunity ID]
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



delete from ProjApproval.InputScreen_Supplements
delete from ProjApproval.InputScreen_Supplements_Trimmed
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_ProjApproval__InputScreen_InputScreen_Supplement_Trim P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__InputScreen_InputScreen_Supplement_Trim

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
