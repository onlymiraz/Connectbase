
CREATE PROCEDURE [ProjApproval].[NewProjIntoExistingOppID]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__NewProjIntoExistingOppID
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[NewProjIntoExistingOppID]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_FTTH__NewProjIntoExistingOppID
FROM [LOG].[Tracker]

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 1]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 1] != ''
and  [Project Number 1] != ' '
and  [Project Number 1] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 1] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 2]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 2] != ''
and  [Project Number 2] != ' '
and  [Project Number 2] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 2] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 3]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 3] != ''
and  [Project Number 3] != ' '
and  [Project Number 3] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 3] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 4]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 4] != ''
and  [Project Number 4] != ' '
and  [Project Number 4] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 4] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 5]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 5] != ''
and  [Project Number 5] != ' '
and  [Project Number 5] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 5] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 6]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 6] != ''
and  [Project Number 6] != ' '
and  [Project Number 6] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 6] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 7]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 7] != ''
and  [Project Number 7] != ' '
and  [Project Number 7] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 7] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 8]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 8] != ''
and  [Project Number 8] != ' '
and  [Project Number 8] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 8] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 9]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 9] != ''
and  [Project Number 9] != ' '
and  [Project Number 9] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 9] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)

insert into ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
(
id, OpportunityID, [Project Number]
)
select id, OpportunityID, [Project Number 10]
from ProjApproval.InputScreen_Projects_ExistingOpportunity
    where [Project Number 10] != ''
and  [Project Number 10] != ' '
and  [Project Number 10] is not null
and ProjApproval.InputScreen_Projects_ExistingOpportunity.[Project Number 10] NOT IN
(select [Project Number]
from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed
)



insert into [ProjApproval].[PreSale_Compiled]
(
[Opportunity ID]
      ,[Project Number]
      ,[Project Description]
      ,[CRC Date]
      ,[BDT#]
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
      ,[Supplement Total ISP Capital - Fully Loaded]
      ,[Supplement Total OSP Capital - Fully Loaded]
      ,[Supplement Total Capital - Fully Loaded]
      ,[Supplement NPV - Fully Loaded]
      ,[Supplement IRR - Fully Loaded]
      ,[Supplement Payback - Fully Loaded]
      ,[Supplement Monthly Expense]
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
      ,[Capital Request]
      ,[Capital Request Q1]
      ,[Capital Request Q2]
      ,[Capital Request Q3]
      ,[Capital Request Q4]
      ,[Capital Cost Future Years]
      ,[Street Address]
      ,[City]
      ,[ZIP Code]
      ,[Link Code]
      ,[Build]
      ,[Grants Name]
      ,[Cost Per Household]
      ,[Household Forecast]
      ,[Take Rate]
      ,[Cost To Connect]
      ,[Video Enabled State]
      ,[Type of Deal]
      ,[Unit Opportunity]
      ,[Cost Per Unit]
      ,[Unit Forecast]
      ,[Take Rate - Engineering/Proforma]
      ,[ROI Take Rate]
      ,[Average Take Rate]
      ,[Total Revenue]
      ,[Competitor]
      ,[Brownfield/Greenfield]
      ,[Notes]
      ,[Additional Documents]
      ,[CRC Date Submitted]
      ,[VP Cap Mgt Approved Date]
      ,[SVP Tech Fin Approval Date]
      ,[ELT Date Submitted]
      ,[ELT Approval Date]
      ,[Final Approval Date]
      ,[Approval Notes]
      ,[Agenda#]
      ,[Presenter First Name]
      ,[Presenter Last Name]
      ,[Presenter Email]
)
SELECT distinct ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed.OpportunityID, ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed.[Project Number], ProjApproval.PreSale_Compiled.[Project Description], 
                  ProjApproval.PreSale_Compiled.[CRC Date], ProjApproval.PreSale_Compiled.BDT#, ProjApproval.PreSale_Compiled.[Budget Category], 
                  ProjApproval.PreSale_Compiled.Exchange, ProjApproval.PreSale_Compiled.State, ProjApproval.PreSale_Compiled.[Total ISP Capital - Fully Loaded], ProjApproval.PreSale_Compiled.[Total OSP Capital - Fully Loaded], 
                  ProjApproval.PreSale_Compiled.[Total Capital - Fully Loaded], ProjApproval.PreSale_Compiled.[MRC - Fully Loaded], ProjApproval.PreSale_Compiled.[CIAC - Fully Loaded], ProjApproval.PreSale_Compiled.[NPV - Fully Loaded], 
                  ProjApproval.PreSale_Compiled.[IRR - Fully Loaded], ProjApproval.PreSale_Compiled.[Payback - Fully Loaded], ProjApproval.PreSale_Compiled.[Supplement Total ISP Capital - Fully Loaded], 
                  ProjApproval.PreSale_Compiled.[Supplement Total OSP Capital - Fully Loaded], ProjApproval.PreSale_Compiled.[Supplement Total Capital - Fully Loaded], ProjApproval.PreSale_Compiled.[Supplement NPV - Fully Loaded], 
                  ProjApproval.PreSale_Compiled.[Supplement IRR - Fully Loaded], ProjApproval.PreSale_Compiled.[Supplement Payback - Fully Loaded], ProjApproval.PreSale_Compiled.[Supplement Monthly Expense], 
                  ProjApproval.PreSale_Compiled.[Total ISP Capital - 20% Loaded], ProjApproval.PreSale_Compiled.[Total OSP Capital - 20% Loaded], ProjApproval.PreSale_Compiled.[Total Capital - 20% Loaded], 
                  ProjApproval.PreSale_Compiled.[MRC - 20% Loaded], ProjApproval.PreSale_Compiled.[CIAC - 20% Loaded], ProjApproval.PreSale_Compiled.[NPV - 20% Loaded], ProjApproval.PreSale_Compiled.[IRR - 20% Loaded], 
                  ProjApproval.PreSale_Compiled.[Payback - 20% Loaded], ProjApproval.PreSale_Compiled.[Term in Months], ProjApproval.PreSale_Compiled.[Bandwidth (Number of Units)], 
                  ProjApproval.PreSale_Compiled.[Bandwidth (Unit of Measurement)], ProjApproval.PreSale_Compiled.NRC, ProjApproval.PreSale_Compiled.[Monthly Expense], ProjApproval.PreSale_Compiled.[Capital Request], 
                  ProjApproval.PreSale_Compiled.[Capital Request Q1], ProjApproval.PreSale_Compiled.[Capital Request Q2], ProjApproval.PreSale_Compiled.[Capital Request Q3], ProjApproval.PreSale_Compiled.[Capital Request Q4], 
                  ProjApproval.PreSale_Compiled.[Capital Cost Future Years], ProjApproval.PreSale_Compiled.[Street Address], ProjApproval.PreSale_Compiled.City, ProjApproval.PreSale_Compiled.[ZIP Code], ProjApproval.PreSale_Compiled.[Link Code], 
                  ProjApproval.PreSale_Compiled.Build, ProjApproval.PreSale_Compiled.[Grants Name], ProjApproval.PreSale_Compiled.[Cost Per Household], ProjApproval.PreSale_Compiled.[Household Forecast], 
                  ProjApproval.PreSale_Compiled.[Take Rate], ProjApproval.PreSale_Compiled.[Cost To Connect], ProjApproval.PreSale_Compiled.[Video Enabled State], ProjApproval.PreSale_Compiled.[Type of Deal], 
                  ProjApproval.PreSale_Compiled.[Unit Opportunity], ProjApproval.PreSale_Compiled.[Cost Per Unit], ProjApproval.PreSale_Compiled.[Unit Forecast], ProjApproval.PreSale_Compiled.[Take Rate - Engineering/Proforma], 
                  ProjApproval.PreSale_Compiled.[ROI Take Rate], ProjApproval.PreSale_Compiled.[Average Take Rate], ProjApproval.PreSale_Compiled.[Total Revenue], ProjApproval.PreSale_Compiled.Competitor, 
                  ProjApproval.PreSale_Compiled.[Brownfield/Greenfield], ProjApproval.PreSale_Compiled.Notes, ProjApproval.PreSale_Compiled.[Additional Documents], ProjApproval.PreSale_Compiled.[CRC Date Submitted], 
                  ProjApproval.PreSale_Compiled.[VP Cap Mgt Approved Date], ProjApproval.PreSale_Compiled.[SVP Tech Fin Approval Date], ProjApproval.PreSale_Compiled.[ELT Date Submitted], ProjApproval.PreSale_Compiled.[ELT Approval Date], 
                  ProjApproval.PreSale_Compiled.[Final Approval Date], ProjApproval.PreSale_Compiled.[Approval Notes], ProjApproval.PreSale_Compiled.Agenda#, ProjApproval.PreSale_Compiled.[Presenter First Name], 
                  ProjApproval.PreSale_Compiled.[Presenter Last Name], ProjApproval.PreSale_Compiled.[Presenter Email]
FROM     ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed INNER JOIN
                  ProjApproval.PreSale_Compiled ON ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed.OpportunityID = ProjApproval.PreSale_Compiled.[Opportunity ID]



delete from ProjApproval.PreSale_Compiled
FROM     ProjApproval.PreSale_Compiled INNER JOIN
                  ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed ON ProjApproval.PreSale_Compiled.[Opportunity ID] = ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed.OpportunityID
where ProjApproval.PreSale_Compiled.[Project Number] like 'TBD'
or ProjApproval.PreSale_Compiled.[Project Number] = ''
or ProjApproval.PreSale_Compiled.[Project Number] is null
or ProjApproval.PreSale_Compiled.[Project Number] = ' '

delete from ProjApproval.InputScreen_Projects_ExistingOpportunity
delete from ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed


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
INNER JOIN LOG.Tracker_Temp_FTTH__NewProjIntoExistingOppID P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__NewProjIntoExistingOppID

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
