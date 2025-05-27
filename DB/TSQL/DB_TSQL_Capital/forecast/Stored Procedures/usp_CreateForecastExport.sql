CREATE PROCEDURE [forecast].[usp_CreateForecastExport]
	@year int
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
					WHERE TABLE_SCHEMA = 'forecast'
					AND TABLE_NAME = 'ForecastExport'))
		BEGIN
			DROP TABLE forecast.ForecastExport
		END

DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_CreateForecastExport
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('forecast.usp_CreateForecastExport'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_CreateForecastExport
FROM [LOG].[Tracker]

----------------------------------------------------------------------------------------------------------
--Both subs selected
update webapp.MSFormsAnalystUpdates
set [Project Sub Number(s)] = 0 where [Project Sub Number(s)] like '%Both%'

--sub 1
DECLARE @S1 table (
	[ID] [varchar](50) NULL,
	[SubmittedBy] [varchar](50) NULL,
	[SubmitttedDtm] [varchar](50) NULL,
	[Username (Frontier CORP ID)] [varchar](50) NULL,
	[Project Number] [varchar](50) NULL,
	[Project Sub Number(s)] [varchar](50) NULL,
	[Spending Not Needed] [varchar](50) NULL,
	[Future Spending] [varchar](50) NULL,
	[Current Project Status] [varchar](50) NULL,
	[Analyst Notes] [varchar](max) NULL)

INSERT INTO @S1 ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM webapp.MSFormsAnalystUpdates
where [Project Sub Number(s)] = 0 or [Project Sub Number(s)] like '%Both%'

UPDATE @S1 SET [Project Sub Number(s)] = 1

--sub 4
DECLARE @S4 table (
	[ID] [varchar](50) NULL,
	[SubmittedBy] [varchar](50) NULL,
	[SubmitttedDtm] [varchar](50) NULL,
	[Username (Frontier CORP ID)] [varchar](50) NULL,
	[Project Number] [varchar](50) NULL,
	[Project Sub Number(s)] [varchar](50) NULL,
	[Spending Not Needed] [varchar](50) NULL,
	[Future Spending] [varchar](50) NULL,
	[Current Project Status] [varchar](50) NULL,
	[Analyst Notes] [varchar](max) NULL)

INSERT INTO @S4 ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM @S1

UPDATE @S4 SET [Project Sub Number(s)] = 4

--Combine both subs
DECLARE @S table (
	[ID] [varchar](50) NULL,
	[SubmittedBy] [varchar](50) NULL,
	[SubmitttedDtm] [varchar](50) NULL,
	[Username (Frontier CORP ID)] [varchar](50) NULL,
	[Project Number] [varchar](50) NULL,
	[Project Sub Number(s)] [varchar](50) NULL,
	[Spending Not Needed] [varchar](50) NULL,
	[Future Spending] [varchar](50) NULL,
	[Current Project Status] [varchar](50) NULL,
	[Analyst Notes] [varchar](max) NULL)

--SUB 1
INSERT INTO @S ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM @S1

--SUB 4
INSERT INTO @S ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM @S4

--FINALIZE and bring back to original table
INSERT INTO [webapp].[MSFormsAnalystUpdates] ([ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes])
SELECT DISTINCT [ID]
      ,[SubmittedBy]
      ,[SubmitttedDtm]
      ,[Username (Frontier CORP ID)]
      ,[Project Number]
      ,[Project Sub Number(s)]
      ,[Spending Not Needed]
      ,[Future Spending]
      ,[Current Project Status]
      ,[Analyst Notes]
FROM @S

--CLEAN 
DELETE FROM [webapp].[MSFormsAnalystUpdates] WHERE [Project Sub Number(s)]=0

----------------------------------------------------------------------------------------------------------

update webapp.MSFormsAnalystUpdates
set [Spending Not Needed] = 0 where [Spending Not Needed] is null
update webapp.MSFormsAnalystUpdates
set [Future Spending] = 0 where [Future Spending] is null

UPDATE forecast.Subproject
SET forecast.Subproject.SubprojectStatus = webapp.MSFormsAnalystUpdates.[Current Project Status]
from forecast.Subproject
inner join webapp.MSFormsAnalystUpdates
on forecast.subproject.ProjectNumber = webapp.MSFormsAnalystUpdates.[Project Number] 
--AND forecast.subproject.SubprojectNumber = webapp.MSFormsAnalystUpdates.[Project Sub Number(s)];

UPDATE forecast.SubprojectFinancial
SET forecast.SubprojectFinancial.SpendingNotNeeded = cast(webapp.MSFormsAnalystUpdates.[Spending Not Needed] as money)
from forecast.SubprojectFinancial
inner join webapp.MSFormsAnalystUpdates
on  forecast.SubprojectFinancial.ProjectNumber = webapp.MSFormsAnalystUpdates.[Project Number] AND forecast.SubprojectFinancial.SubprojectNumber = webapp.MSFormsAnalystUpdates.[Project Sub Number(s)];

UPDATE forecast.SubprojectFutureYear
SET forecast.SubprojectFutureYear.Spend = cast(webapp.MSFormsAnalystUpdates.[Future Spending] as money)
from forecast.SubprojectFutureYear
inner join webapp.MSFormsAnalystUpdates
on forecast.SubprojectFutureYear.ProjectNumber = webapp.MSFormsAnalystUpdates.[Project Number] AND forecast.SubprojectFutureYear.SubprojectNumber = webapp.MSFormsAnalystUpdates.[Project Sub Number(s)];



update webapp.MSFormsAnalystUpdates
set [Analyst Notes] = cast(cast(SubmitttedDtm as date) as nvarchar(10))+'-'+left(SubmittedBy,6)+'-'+[Analyst Notes]
where ID is not null


--Add previous notes
update M
set M.[Analyst Notes]=M.[Analyst Notes]+' '+D.[Analyst Notes]
from webapp.MSFormsAnalystUpdates M,
webapp.MSFormsAnalystUpdatesLatestDetails D
where M.[Project Number]=D.[Project Number]
--and M.[Sub #]=D.[Project Sub Number(s)]
and M.[Analyst Notes]!=D.[Analyst Notes]




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT 	S.ProjectNumber AS ProjectNumber,
		S.SubprojectNumber AS SubprojectNumber,
		((S.ProjectNumber * 10) + S.SubprojectNumber) AS ProjectSubNumber,
		S.BudgetLineNumber AS BudgetLineNumber,
		B.BudgetLineName AS BudgetLineName,
		P.ClassOfPlant AS ClassOfPlant,
		P.LinkCode AS LinkCode,
		IIF(P.SubBudgetCategoryID IS NOT NULL, IIF(SBC.Overwrite = 1, SBC.SubBudgetCategory, PBC.BudgetCategory + ' ' + IIF(SBC.Separator IS NOT NULL, SBC.Separator + ' ', '') + SBC.SubBudgetCategory), IIF(P.BudgetCategoryID IS NOT NULL, PBC.BudgetCategory, JBC.BudgetCategory))
			+ IIF(P.SubBudgetCategoryID IS NULL, IIF(P.BudgetCategoryID IS NULL, IIF(JBC.HasCarryIn = 1 AND S.CarryIn = 1, ' Carry-In', ''), IIF(PBC.HasCarryIn = 1 AND S.CarryIn = 1, ' Carry-In', '')), IIF(SBC.HasCarryIn = 1 AND S.CarryIn = 1, ' Carry-In', '')) AS BudgetCategory,
		FC.FinanceCategory AS FinanceCategory,
		P.JustificationCode AS JustificationCode,
		P.FunctionalGroup AS FunctionalGroup,
		P.ProjectDescription AS ProjectDescription,
		P.Billable AS [Billable],
		S.ProjectStatusCode AS ProjectStatusCode,
		P.ApprovalCode AS ApprovalCode,
		P.ProjectType AS ProjectType,
		P.Company AS [Company],
		P.ExchangeName AS [Exchange],
		P.OperatingArea AS OperatingArea,
		P.[State] AS [State],
		P.Engineer AS [Engineer],
		P.ProjectOwner AS [ProjectOwner],
		S.ApprovalDate AS [ApprovalDate],
		S.EstimatedStartDate AS EstimatedStartDate,
		S.EstimatedCompleteDate AS EstimatedCompleteDate,
		S.ActualStartDate AS ActualStartDate,
		S.ReadyForServiceDate AS ReadyForServiceDate,
		S.TentativeCloseDate AS TentativeCloseDate,
		S.CloseDate AS [CloseDate],
		AUTH.Direct AS AuthorizedDirect,
		AUTH.Indirect AS AuthorizedIndirect,
		(AUTH.Direct + AUTH.Indirect) AS AuthorizedTotal,
		ISNULL(ROUND(PY.Direct, 2), 0) AS PriorYearsSpendDirect,
		ISNULL(ROUND(PY.Indirect, 2), 0) AS PriorYearsSpendIndirect,
		ISNULL(ROUND(PY.Direct + PY.Indirect, 2), 0) AS PriorYearsSpendTotal,
		--0.0 AS ProjectVariance,
		--0.0 AS PercentOverUnder,
		NULL AS SpendingForecast,
		ISNULL(GD.January, 0) AS JanuaryDirect,
		ISNULL(GI.January, 0) AS JanuaryIndirect,
		ISNULL(GD.February, 0) AS [FebruaryDirect],
		ISNULL(GI.February, 0) AS [FebruaryIndirect],
		ISNULL(GD.March, 0) AS [MarchDirect],
		ISNULL(GI.March, 0) AS [MarchIndirect],
		ISNULL(GD.April, 0) AS [AprilDirect],
		ISNULL(GI.April, 0) AS [AprilIndirect],
		ISNULL(GD.May, 0) AS [MayDirect],
		ISNULL(GI.May, 0) AS [MayIndirect],
		ISNULL(GD.June, 0) AS [JuneDirect],
		ISNULL(GI.June, 0) AS [JuneIndirect],
		ISNULL(GD.July, 0) AS [JulyDirect],
		ISNULL(GI.July, 0) AS [JulyIndirect],
		ISNULL(GD.August, 0) AS [AugustDirect],
		ISNULL(GI.August, 0) AS [AugustIndirect],
		ISNULL(GD.September, 0) AS [SeptemberDirect],
		ISNULL(GI.September, 0) AS [SeptemberIndirect],
		ISNULL(GD.October, 0) AS [OctoberDirect],
		ISNULL(GI.October, 0) AS [OctoberIndirect],
		ISNULL(GD.November, 0) AS [NovemberDirect],
		ISNULL(GI.November, 0) AS [NovemberIndirect],
		ISNULL(GD.December, 0) AS [DecemberDirect],
		ISNULL(GI.December, 0) AS [DecemberIndirect],
		ISNULL((GD.January + GD.February + GD.March + GD.April + GD.May + GD.June + GD.July + GD.August + GD.September + GD.October + GD.November + GD.December), 0) AS GrossAddsDirect,
		ISNULL((GI.January + GI.February + GI.March + GI.April + GI.May + GI.June + GI.July + GI.August + GI.September + GI.October + GI.November + GI.December), 0) AS GrossAddsIndirect,
		ISNULL((GD.January + GD.February + GD.March + GD.April + GD.May + GD.June + GD.July + GD.August + GD.September + GD.October + GD.November + GD.December +
		GI.January + GI.February + GI.March + GI.April + GI.May + GI.June + GI.July + GI.August + GI.September + GI.October + GI.November + GI.December), 0) AS GrossAddsTotal,
		CIAC.Spend AS [CIACSpend],
		FY.SpendInfinium AS [FutureYearsSpendInfinium],
		IIF(FY.SpendInfinium = 0, FY.Spend, 0) AS [FutureYearsSpend],
		0 AS [SpendingNotNeededDirect],
		0 As [SpendingNotNeededIndirect],
		F.SpendingNotNeeded AS [SpendingNotNeeded],
		0 AS [RemainderToSpendDirect],
		0 AS [RemainderToSpendIndirect],
		0 AS [RemainderToSpend],
		F.AdditionalDollarsNeeded AS [AdditionalDollarsNeeded],
		--0.0 AS [Q1Direct],
		--0.0 AS [Q1Indirect],
		--0.0 AS [Q2Direct],
		--0.0 AS [Q2Indirect],
		--0.0 AS [Q3Direct],
		--0.0 AS [Q3Indirect],
		--0.0 AS [Q4Direct],
		--0.0 AS [Q4Indirect],
		--0.0 AS [QuarterlyDirect],
		--0.0 AS [QuarterlyIndirect],
		--0.0 AS [QuarterlyTotal],
		CIAC.Budget AS [CIACBudget],
		CAST(NULL AS varchar(4000)) AS [AnalystNotes],
		S.SubprojectStatus AS SubprojectStatus,
		S.VarassetStatus AS VarassetStatus,
		S.VarassetStatusModifiedDate AS VarassetStatusDate,
		S.VarassetClosingIssue AS VarassetClosingIssue,
		S.VarassetScheduledFinishDate AS VarassetScheduledFinishDate,
		IIF(S.CarryIn = 0, CAST(@year AS VARCHAR(4)), 'Carry-In') AS [CarryIn],
		S.SentToClosing AS [SentToClosing]
INTO forecast.ForecastExport
FROM forecast.Project AS P INNER JOIN forecast.Subproject AS S ON P.ProjectNumber = S.ProjectNumber
		LEFT JOIN forecast.BudgetLine AS B ON S.BudgetLineNumber = B.BudgetLineNumber
		LEFT JOIN forecast.JustificationCode AS JC ON P.JustificationCode = JC.JustificationCode
		LEFT JOIN forecast.BudgetCategory AS JBC ON JC.BudgetCategoryID = JBC.ID
		LEFT JOIN forecast.BudgetCategory AS PBC ON P.BudgetCategoryID = PBC.ID
		LEFT JOIN forecast.SubBudgetCategory AS SBC ON P.SubBudgetCategoryID = SBC.ID
		LEFT JOIN forecast.FinanceCategory AS FC ON P.JustificationCode = FC.JustificationCode
		LEFT JOIN forecast.GrossAddsDirect AS GD ON S.ProjectNumber = GD.ProjectNumber AND S.SubprojectNumber = GD.SubprojectNumber AND GD.[Year] = @year
		LEFT JOIN forecast.GrossAddsIndirect AS GI ON S.ProjectNumber = GI.ProjectNumber AND S.SubprojectNumber = GI.SubprojectNumber AND GI.[Year] = @year
		--LEFT JOIN forecast.ProjectStatusCode AS PSC ON S.ProjectStatusCodeID = PSC.ID
		LEFT JOIN forecast.SubprojectAuthorized AS AUTH ON S.ProjectNumber = AUTH.ProjectNumber AND S.SubprojectNumber = AUTH.SubprojectNumber
		LEFT JOIN forecast.SubprojectCIAC AS CIAC ON S.ProjectNumber = CIAC.ProjectNumber AND S.SubprojectNumber = CIAC.SubprojectNumber
		LEFT JOIN forecast.SubprojectFinancial AS F ON S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber
		LEFT JOIN forecast.SubprojectFutureYear AS FY ON S.ProjectNumber = FY.ProjectNumber AND S.SubprojectNumber = FY.SubprojectNumber
		LEFT JOIN forecast.SubprojectPriorYear3 AS PY ON S.ProjectNumber = PY.ProjectNumber AND S.SubprojectNumber = PY.SubprojectNumber
		--LEFT JOIN forecast.SubprojectStatus AS STS ON S.SubprojectStatusID = STS.ID
ORDER BY S.ProjectNumber, S.SubprojectNumber ASC

UPDATE forecast.ForecastExport
SET GrossAddsTotal=GrossAddsDirect+GrossAddsIndirect
		
/*
SELECT S.ProjectNumber AS [Proj Num],
		S.SubprojectNumber AS [Sub Num],
		(S.ProjectNumber + S.SubprojectNumber) AS [Proj/Sub Number],
		ISNULL(S.BudgetLineNumber, '') AS [Budget Line Num],
		ISNULL(B.BudgetLineName, '') AS [Budget Line Name],
		ISNULL(P.ClassOfPlant, '') AS [Class of Plant],
		ISNULL(P.LinkCode, '') AS [Link Code],
		ISNULL(P.BudgetCategory + IIF(P.JustificationCode IN (20, 21, 22, 23, 24, 25, 76), '', IIF(P.JustificationCode = 81, IIF(P.BudgetCategory LIKE '%Network Projects%' OR P.BudgetCategory LIKE '%IT/Video Strategic Projects%', IIF(S.CarryIn = 1, ' Carry-In', ''), ''), IIF(S.CarryIn = 1, ' Carry-In', ''))), '') AS [Budget Category],
		ISNULL(P.JustificationCode, '') AS [Just Code],
		ISNULL(P.FunctionalGroup, '') AS [Group],
		ISNULL(P.ProjectDescription, '') AS [Project Description],
		ISNULL(P.Billable, '') AS [Billable],
		ISNULL(S.ProjectStatusCode, '') AS [Proj Status],
		ISNULL(P.ApprovalCode, '') AS [Appr Code],
		ISNULL(P.ProjectType, '') AS [Project Type],
		ISNULL(P.Company, '') AS [Company],
		ISNULL(P.ExchangeName, '') AS [Exchange],
		ISNULL(P.OperatingArea, '') AS [OA],
		ISNULL(P.[State], '') AS [State],
		ISNULL(P.Engineer, '') AS [Engineer],
		ISNULL(P.ProjectOwner, '') AS [Project Owner],
		S.ApprovalDate AS [Approval Date],
		S.EstimatedStartDate AS [Est Start Date],
		S.EstimatedCompleteDate AS [Est Comp Date],
		S.ActualStartDate AS [Act Start Date],
		S.ReadyForServiceDate AS [Rdy For Svc Date],
		S.TentativeCloseDate AS [Tent Close Date],
		S.CloseDate AS [Close Date],
		F.AuthorizedDirect AS [Current Project Authorized Direct],
		F.AuthorizedIndirect AS [Current Project Authorized Indirect],
		F.AuthorizedDirect + F.AuthorizedIndirect AS [Current Project Authorized Amount],
		F.PriorYearsSpent AS [Prior Years Spent],
		--0 AS [Project Variance],
		--0 AS [% Over/Under],
		NULL AS [Yearend Spending Forecast],
		GD.January AS [January Adds Direct],
		GI.January AS [January Adds Indirect],
		GD.February AS [February Adds Direct],
		GI.February AS [February Adds Indirect],
		GD.March AS [March Adds Direct],
		GI.March AS [March Adds Indirect],
		GD.April AS [April Adds Direct],
		GI.April AS [April Adds Indirect],
		GD.May AS [May Adds Direct],
		GI.May AS [May Adds Indirect],
		GD.June AS [June Adds Direct],
		GI.June AS [June Adds Indirect],
		GD.July AS [July Adds Direct],
		GI.July AS [July Adds Indirect],
		GD.August AS [August Adds Direct],
		GI.August AS [August Adds Indirect],
		GD.September AS [September Adds Direct],
		GI.September AS [September Adds Indirect],
		GD.October AS [October Adds Direct],
		GI.October AS [October Adds Indirect],
		GD.November AS [November Adds Direct],
		GI.November AS [November Adds Indirect],
		GD.December AS [December Adds Direct],
		GI.December AS [December Adds Indirect],
		(GD.January + GD.February + GD.March + GD.April + GD.May + GD.June + GD.July + GD.August + GD.September + GD.October + GD.November + GD.December) AS [YTD Direct],
		(GI.January + GI.February + GI.March + GI.April + GI.May + GI.June + GI.July + GI.August + GI.September + GI.October + GI.November + GI.December) AS [YTD Indirect],
		(GD.January + GD.February + GD.March + GD.April + GD.May + GD.June + GD.July + GD.August + GD.September + GD.October + GD.November + GD.December +
		GI.January + GI.February + GI.March + GI.April + GI.May + GI.June + GI.July + GI.August + GI.September + GI.October + GI.November + GI.December) AS [YTD Gross Adds],
		F.AllCIAC AS [All CIAC],
		F.FutureYearsSpendingInfinium AS [Future Years Spending - Infinium],
		F.FutureYearsSpending AS [Future Years Spending],
		F.SpendingNotNeeded AS [Spending Not Needed],
		NULL AS [Remainder To Spend Thru Year End],
		F.AdditionalDollarsNeeded AS [Additional $ Needed],
		--0 AS [Q1 Direct],
		--0 AS [Q1 Indirect],
		--0 AS [Q2 Direct],
		--0 AS [Q2 Indirect],
		--0 AS [Q3 Direct],
		--0 AS [Q3 Indirect],
		--0 AS [Q4 Direct],
		--0 AS [Q4 Indirect],
		--0 AS [Total Released Direct],
		--0 AS [Total Released Indirect],
		--0 AS [Grand Total Released],
		F.CIACBudget AS [CIAC Budget],
		ISNULL(S.AnalystNotes, '') AS [Analyst Notes],
		ISNULL(S.SubprojectStatus, '') AS [Current Project Status],
		IIF(S.CarryIn = 1, 'Carry-In', '2018') AS [Carry-In],
		S.SentToClosing AS [Sent to Closing]
INTO forecast.ForecastExport
FROM forecast.Project AS P INNER JOIN ((((forecast.Subproject AS S INNER JOIN forecast.SubprojectFinancial AS F ON S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber) LEFT JOIN forecast.GrossAddsDirect AS GD ON S.ProjectNumber = GD.ProjectNumber AND S.SubprojectNumber = GD.SubprojectNumber AND GD.[Year] = YEAR(GETDATE())) LEFT JOIN forecast.GrossAddsIndirect AS GI ON S.ProjectNumber = GI.ProjectNumber AND S.SubprojectNumber = GI.SubprojectNumber AND GI.[Year] = YEAR(GETDATE())) LEFT JOIN forecast.BudgetLine AS B ON S.BudgetLineNumber = B.BudgetLineNumber) ON P.ProjectNumber = S.ProjectNumber
ORDER BY P.ProjectNumber, S.SubprojectNumber ASC
*/


UPDATE [forecast].[ForecastExport]
SET [FutureYearsSpendInfinium] = 0 WHERE [FutureYearsSpendInfinium] IS NULL

UPDATE [forecast].[ForecastExport]
SET [FutureYearsSpend] = 0 WHERE [FutureYearsSpend] IS NULL

UPDATE [forecast].[ForecastExport]
SET [PriorYearsSpendDirect] = 0 WHERE [PriorYearsSpendDirect] IS NULL

UPDATE [forecast].[ForecastExport]
SET [AuthorizedTotal] = 0 WHERE [AuthorizedTotal] IS NULL

UPDATE [forecast].[ForecastExport] 
SET [AuthorizedDirect] = 0 WHERE [AuthorizedDirect] IS NULL

UPDATE [forecast].[ForecastExport] 
SET [AuthorizedIndirect] = 0 WHERE [AuthorizedIndirect] IS NULL

UPDATE [forecast].[ForecastExport]
SET [FutureYearsSpend] = 0 WHERE [FutureYearsSpend] IS NULL

UPDATE [forecast].[ForecastExport]
SET [GrossAddsTotal] = 0 WHERE [GrossAddsTotal] IS NULL

UPDATE [forecast].[ForecastExport] 
SET [CIACSpend] = 0 WHERE [CIACSpend] IS NULL

UPDATE [forecast].[ForecastExport] 
SET [SpendingNotNeeded] = 0 WHERE [SpendingNotNeeded] IS NULL

UPDATE [forecast].[ForecastExport] 
SET [SpendingNotNeededDirect] = 0 WHERE [SpendingNotNeededDirect] IS NULL

UPDATE [forecast].[ForecastExport] 
SET [SpendingNotNeededIndirect] = 0 WHERE [SpendingNotNeededIndirect] IS NULL

UPDATE [forecast].[ForecastExport] 
SET [PriorYearsSpendTotal] = 0 WHERE [PriorYearsSpendTotal] IS NULL

UPDATE [forecast].[ForecastExport] 
SET [PriorYearsSpendDirect] = 0 WHERE [PriorYearsSpendDirect] IS NULL

UPDATE [forecast].[ForecastExport] 
SET [PriorYearsSpendIndirect] = 0 WHERE [PriorYearsSpendIndirect] IS NULL


UPDATE forecast.ForecastExport
SET [RemainderToSpendDirect] = IIF(([ProjectStatusCode] IN ('CL', 'CX') AND ([FutureYearsSpendInfinium] + [FutureYearsSpend] = 0)) OR ([AuthorizedTotal] - [PriorYearsSpendDirect] - [FutureYearsSpendInfinium] - [FutureYearsSpend] - [GrossAddsTotal] + [CIACSpend] - [SpendingNotNeeded] < 0), 
													[GrossAddsDirect], 
													([AuthorizedDirect] - [PriorYearsSpendDirect] - [FutureYearsSpendInfinium] - [FutureYearsSpend] + [CIACSpend] - [SpendingNotNeeded])) - [GrossAddsDirect],
	[RemainderToSpendIndirect] = IIF(([ProjectStatusCode] IN ('CL', 'CX') AND ([FutureYearsSpendInfinium] + [FutureYearsSpend] = 0)) OR ([AuthorizedTotal] - [PriorYearsSpendIndirect] - [FutureYearsSpendInfinium] - [FutureYearsSpend] - [GrossAddsTotal] + [CIACSpend] - [SpendingNotNeeded] < 0), 
													[GrossAddsIndirect], 
													([AuthorizedIndirect] - [PriorYearsSpendIndirect] - [FutureYearsSpendInfinium] - [FutureYearsSpend] + [CIACSpend] - [SpendingNotNeeded])) - [GrossAddsIndirect],
	[RemainderToSpend] = IIF(([ProjectStatusCode] IN ('CL', 'CX') AND ([FutureYearsSpendInfinium] + [FutureYearsSpend] = 0)) OR ([AuthorizedTotal] - [PriorYearsSpendTotal] - [FutureYearsSpendInfinium] - [FutureYearsSpend] - [GrossAddsTotal] + [CIACSpend] - [SpendingNotNeeded] < 0), 
													[GrossAddsTotal], 
													([AuthorizedTotal] - [PriorYearsSpendTotal] - [FutureYearsSpendInfinium] - [FutureYearsSpend] + [CIACSpend] - [SpendingNotNeeded])) - [GrossAddsTotal]

--UPDATE F
--SET F.[AnalystNotes] = P.[Notes]
--FROM forecast.ForecastExport F INNER JOIN
--(SELECT N.ProjectNumber, IIF(N.CreatedBy <> 'sys', FORMAT(N.CreatedDate, 'MM/dd/yy') + ' ' + N.CreatedBy + ': ', '') + N.[Text] AS [Notes]
--FROM forecast.Note N INNER JOIN
--	(SELECT ProjectNumber, MAX(ID) AS ID, MAX([Text]) AS [Text], MAX(CreatedDate) AS [CreatedDate]
--	FROM forecast.Note
--	GROUP BY ProjectNumber) O
--ON N.ID = O.ID) P ON F.ProjectNumber = P.ProjectNumber

--------------------------------------------------------------------------------------------------------


insert into history.note
(ProjectNumber, SubprojectNumber, [text], CreatedBy, CreatedDate)
select [Project Number],[Project Sub Number(s)], [Analyst Notes], [SubmittedBy],[SubmitttedDtm]
from webapp.MSFormsAnalystUpdates
where [Analyst Notes] is not null


truncate table [forecast].[notefinal] 
insert into forecast.NoteFinal 
( [ProjectNumber], [SubProjectnumber], [Note], [createdby], [createddate] ) 
SELECT distinct
    [ProjectNumber], [SubprojectNumber], [Text], [CreatedBy], max([CreatedDate]) 
FROM [history].[note] 
where [history].[note].[Text] is not null
group by
    [ProjectNumber],
    [SubprojectNumber],
    [Text],
    [CreatedBy] 
	
UPDATE forecast.ForecastExport 
SET AnalystNotes = LEFT(forecast.NoteFinal.note,4000)
from forecast.ForecastExport 
inner join forecast.NoteFinal on 
[forecast].[NoteFinal].[ProjectNumber] = forecast.ForecastExport.[ProjectNumber]       
--and [forecast].[NoteFinal].[SubProjectnumber] = forecast.ForecastExport.[SubprojectNumber]


--------------------------------------------------------------------------------------------------------


	DELETE FROM forecast.ForecastExport
	WHERE ProjectStatusCode IN ('CL', 'CX') AND
		JanuaryDirect = 0 AND JanuaryIndirect = 0 AND
		FebruaryDirect = 0 AND FebruaryIndirect = 0 AND
		MarchDirect = 0 AND MarchIndirect = 0 AND
		AprilDirect = 0 AND AprilIndirect = 0 AND
		MayDirect = 0 AND MayIndirect = 0 AND
		JuneDirect = 0 AND JuneIndirect = 0 AND
		JulyDirect = 0 AND JulyIndirect = 0 AND
		AugustDirect = 0 AND AugustIndirect = 0 AND
		SeptemberDirect = 0 AND SeptemberIndirect = 0 AND
		OctoberDirect = 0 AND OctoberIndirect = 0 AND
		NovemberDirect = 0 AND NovemberIndirect = 0 AND
		DecemberDirect = 0 AND DecemberIndirect = 0
-------------------------------------------------------------------------------------------------------------------------		
--CarryIn Field
declare @yy int = cast(right(cast(@year as nvarchar(4)),2) as int)

UPDATE forecast.ForecastExport
SET CarryIn = IIF(E.[AP Code]='','Multi-yr',IIF((E.[Bdgt Yr] + E.[Proj Life (Yrs)] -1)>=@yy,IIF(((E.[Bdgt Yr] = @yy) AND (E.[Proj Life (Yrs)] <= 1)),cast(@year as nvarchar(4)),'Multi-yr'),'Carry-In'))
FROM forecast.forecastexport AS F 
LEFT JOIN dbo.estimate AS E ON F.ProjectNumber = E.[PJ #]

-------------------------------------------------------------------------------------------------------------
--Future Year Correction

DROP TABLE forecast.CorrectFutureYearSpend


SELECT forecast.ForecastExport.ProjectNumber, forecast.ForecastExport.SubprojectNumber, forecast.ForecastExport.FutureYearsSpend as FutureYearsSpend_Incorrect, forecast.SubprojectFutureYear.Spend as FutureYearsSpend_Correct
into forecast.CorrectFutureYearSpend
FROM     forecast.ForecastExport LEFT OUTER JOIN
                forecast.SubprojectFutureYear ON forecast.ForecastExport.ProjectNumber = forecast.SubprojectFutureYear.ProjectNumber AND forecast.ForecastExport.SubprojectNumber = forecast.SubprojectFutureYear.SubprojectNumber
where forecast.ForecastExport.FutureYearsSpend != forecast.SubprojectFutureYear.Spend


UPDATE forecast.ForecastExport
SET FutureYearsSpend = forecast.CorrectFutureYearSpend.FutureYearsSpend_Correct
FROM     forecast.ForecastExport LEFT OUTER JOIN
                forecast.CorrectFutureYearSpend ON forecast.ForecastExport.ProjectNumber = forecast.CorrectFutureYearSpend.ProjectNumber AND forecast.ForecastExport.SubprojectNumber = forecast.CorrectFutureYearSpend.SubprojectNumber



update FE
SET FE.FutureYearsSpend=MS.[Future Spending]
from forecast.ForecastExport AS FE,
webapp.MSFormsAnalystUpdatesLatestDetails AS MS
WHERE FE.ProjectNumber=MS.[Project Number]
AND FE.SubprojectNumber=MS.[Project Sub Number(s)]

---------------------------------------------------------------------------------------------------------------------------		

--Correct AnalystNote
INSERT into webapp.MSFormsAnalystUpdatesHistory 
select * from webapp.MSFormsAnalystUpdates	

TRUNCATE TABLE webapp.MSFormsAnalystUpdates

UPDATE [webapp].[MSFormsAnalystUpdatesHistory]
SET [Project Number] = REPLACE([Project Number],'.','')

drop table [webapp].[MSFormsAnalystUpdatesLatest]
SELECT [Project Number], [Project Sub Number(s)], max(cast(SubmitttedDtm as datetime)) as LatestDateTime
into [webapp].[MSFormsAnalystUpdatesLatest]
FROM [webapp].[MSFormsAnalystUpdatesHistory]
where [Project Number] is not null
and [Project Number] != 0
and [Project Sub Number(s)] is not null
and [Project Sub Number(s)] != 0
group by [Project Number], [Project Sub Number(s)]

DROP TABLE webapp.MSFormsAnalystUpdatesLatestDetails
SELECT distinct webapp.MSFormsAnalystUpdatesLatest.[Project Number], webapp.MSFormsAnalystUpdatesLatest.[Project Sub Number(s)], webapp.MSFormsAnalystUpdatesLatest.LatestDateTime, webapp.MSFormsAnalystUpdatesHistory.ID, 
                webapp.MSFormsAnalystUpdatesHistory.SubmittedBy, webapp.MSFormsAnalystUpdatesHistory.[Username (Frontier CORP ID)], webapp.MSFormsAnalystUpdatesHistory.[Spending Not Needed], 
                webapp.MSFormsAnalystUpdatesHistory.[Future Spending], webapp.MSFormsAnalystUpdatesHistory.[Current Project Status], webapp.MSFormsAnalystUpdatesHistory.[Analyst Notes]
INTO webapp.MSFormsAnalystUpdatesLatestDetails
FROM     webapp.MSFormsAnalystUpdatesLatest INNER JOIN
                webapp.MSFormsAnalystUpdatesHistory ON webapp.MSFormsAnalystUpdatesLatest.[Project Number] = webapp.MSFormsAnalystUpdatesHistory.[Project Number] AND 
                webapp.MSFormsAnalystUpdatesLatest.[Project Sub Number(s)] = webapp.MSFormsAnalystUpdatesHistory.[Project Sub Number(s)] AND 
                webapp.MSFormsAnalystUpdatesLatest.LatestDateTime = webapp.MSFormsAnalystUpdatesHistory.SubmitttedDtm


update forecast.ForecastExport
set AnalystNotes = LEFT(webapp.MSFormsAnalystUpdatesLatestDetails.[Analyst Notes],4000)
FROM     forecast.ForecastExport INNER JOIN
                webapp.MSFormsAnalystUpdatesLatestDetails ON forecast.ForecastExport.ProjectNumber = webapp.MSFormsAnalystUpdatesLatestDetails.[Project Number] 
				--AND forecast.ForecastExport.SubprojectNumber = webapp.MSFormsAnalystUpdatesLatestDetails.[Project Sub Number(s)]


------------------------------------------------------------------------------------------------------
----Correct Prior Year
--update forecast.ForecastExport
--set PriorYearsSpendDirect = prioryear.direct
--FROM     forecast.ForecastExport INNER JOIN
--                  prioryear ON forecast.ForecastExport.ProjectNumber = prioryear.ProjectNumber AND forecast.ForecastExport.SubprojectNumber = prioryear.SubprojectNumber
--where prioryear.direct is not null
--and prioryear.[year] = 2019

--update forecast.ForecastExport
--set PriorYearsSpendinDirect = prioryear.indirect
--FROM     forecast.ForecastExport INNER JOIN
--                  prioryear ON forecast.ForecastExport.ProjectNumber = prioryear.ProjectNumber AND forecast.ForecastExport.SubprojectNumber = prioryear.SubprojectNumber
--where prioryear.indirect is not null
--and prioryear.[year] = 2019

--update forecast.ForecastExport
--set PriorYearsSpendtotal = prioryear.[total]
--FROM     forecast.ForecastExport INNER JOIN
--                  prioryear ON forecast.ForecastExport.ProjectNumber = prioryear.ProjectNumber AND forecast.ForecastExport.SubprojectNumber = prioryear.SubprojectNumber
--where prioryear.[total] is not null
--and prioryear.[year] = 2019
---------------------------------------------------------------------------------------------------------------------------		
TRUNCATE TABLE forecast.[ForecastExportCopy]
	INSERT INTO forecast.[ForecastExportCopy]
        ([ProjectNumber]
        ,[SubprojectNumber]
        ,[ProjectSubNumber]
        ,[BudgetLineNumber]
        ,[BudgetLineName]
        ,[ClassOfPlant]
        ,[LinkCode]
        ,[BudgetCategory]
        ,[FinanceCategory]
        ,[JustificationCode]
        ,[FunctionalGroup]
        ,[ProjectDescription]
        ,[Billable]
        ,[ProjectStatusCode]
        ,[ApprovalCode]
        ,[ProjectType]
        ,[Company]
        ,[Exchange]
        ,[OperatingArea]
        ,[State]
        ,[Engineer]
        ,[ProjectOwner]
        ,[ApprovalDate]
        ,[EstimatedStartDate]
        ,[EstimatedCompleteDate]
        ,[ActualStartDate]
        ,[ReadyForServiceDate]
        ,[TentativeCloseDate]
        ,[CloseDate]
        ,[AuthorizedDirect]
        ,[AuthorizedIndirect]
        ,[AuthorizedTotal]
        ,[PriorYearsSpendDirect]
        ,[PriorYearsSpendIndirect]
        ,[PriorYearsSpendTotal]
        ,[SpendingForecast]
        ,[JanuaryDirect]
        ,[JanuaryIndirect]
        ,[FebruaryDirect]
        ,[FebruaryIndirect]
        ,[MarchDirect]
        ,[MarchIndirect]
        ,[AprilDirect]
        ,[AprilIndirect]
        ,[MayDirect]
        ,[MayIndirect]
        ,[JuneDirect]
        ,[JuneIndirect]
        ,[JulyDirect]
        ,[JulyIndirect]
        ,[AugustDirect]
        ,[AugustIndirect]
        ,[SeptemberDirect]
        ,[SeptemberIndirect]
        ,[OctoberDirect]
        ,[OctoberIndirect]
        ,[NovemberDirect]
        ,[NovemberIndirect]
        ,[DecemberDirect]
        ,[DecemberIndirect]
        ,[GrossAddsDirect]
        ,[GrossAddsIndirect]
        ,[GrossAddsTotal]
        ,[CIACSpend]
        ,[FutureYearsSpendInfinium]
        ,[FutureYearsSpend]
        ,[SpendingNotNeededDirect]
        ,[SpendingNotNeededIndirect]
        ,[SpendingNotNeeded]
        ,[RemainderToSpendDirect]
        ,[RemainderToSpendIndirect]
        ,[RemainderToSpend]
        ,[AdditionalDollarsNeeded]
        ,[CIACBudget]
        ,[AnalystNotes]
        ,[SubprojectStatus]
        ,[VarassetStatus]
        ,[VarassetStatusDate]
        ,[VarassetClosingIssue]
        ,[VarassetScheduledFinishDate]
        ,[CarryIn]
        ,[SentToClosing])
    select
        [ProjectNumber]
        ,[SubprojectNumber]
        ,[ProjectSubNumber]
        ,[BudgetLineNumber]
        ,[BudgetLineName]
        ,[ClassOfPlant]
        ,[LinkCode]
        ,[BudgetCategory]
        ,[FinanceCategory]
        ,[JustificationCode]
        ,[FunctionalGroup]
        ,[ProjectDescription]
        ,[Billable]
        ,[ProjectStatusCode]
        ,[ApprovalCode]
        ,[ProjectType]
        ,[Company]
        ,[Exchange]
        ,[OperatingArea]
        ,[State]
        ,[Engineer]
        ,[ProjectOwner]
        ,[ApprovalDate]
        ,[EstimatedStartDate]
        ,[EstimatedCompleteDate]
        ,[ActualStartDate]
        ,[ReadyForServiceDate]
        ,[TentativeCloseDate]
        ,[CloseDate]
        ,[AuthorizedDirect]
        ,[AuthorizedIndirect]
        ,[AuthorizedTotal]
        ,[PriorYearsSpendDirect]
        ,[PriorYearsSpendIndirect]
        ,[PriorYearsSpendTotal]
        ,[SpendingForecast]
        ,[JanuaryDirect]
        ,[JanuaryIndirect]
        ,[FebruaryDirect]
        ,[FebruaryIndirect]
        ,[MarchDirect]
        ,[MarchIndirect]
        ,[AprilDirect]
        ,[AprilIndirect]
        ,[MayDirect]
        ,[MayIndirect]
        ,[JuneDirect]
        ,[JuneIndirect]
        ,[JulyDirect]
        ,[JulyIndirect]
        ,[AugustDirect]
        ,[AugustIndirect]
        ,[SeptemberDirect]
        ,[SeptemberIndirect]
        ,[OctoberDirect]
        ,[OctoberIndirect]
        ,[NovemberDirect]
        ,[NovemberIndirect]
        ,[DecemberDirect]
        ,[DecemberIndirect]
        ,[GrossAddsDirect]
        ,[GrossAddsIndirect]
        ,[GrossAddsTotal]
        ,[CIACSpend]
        ,[FutureYearsSpendInfinium]
        ,[FutureYearsSpend]
        ,[SpendingNotNeededDirect]
        ,[SpendingNotNeededIndirect]
        ,[SpendingNotNeeded]
        ,[RemainderToSpendDirect]
        ,[RemainderToSpendIndirect]
        ,[RemainderToSpend]
        ,[AdditionalDollarsNeeded]
        ,[CIACBudget]
        ,[AnalystNotes]
        ,[SubprojectStatus]
        ,[VarassetStatus]
        ,[VarassetStatusDate]
        ,[VarassetClosingIssue]
        ,[VarassetScheduledFinishDate]
        ,[CarryIn]
        ,[SentToClosing]
from forecast.ForecastExport
----------------------------------------------------------------------------------------------------
--FF History
	INSERT INTO history.ForecastExport
        ([ProjectNumber]
        ,[SubprojectNumber]
        ,[ProjectSubNumber]
        ,[BudgetLineNumber]
        ,[BudgetLineName]
        ,[ClassOfPlant]
        ,[LinkCode]
        ,[BudgetCategory]
        ,[FinanceCategory]
        ,[JustificationCode]
        ,[FunctionalGroup]
        ,[ProjectDescription]
        ,[Billable]
        ,[ProjectStatusCode]
        ,[ApprovalCode]
        ,[ProjectType]
        ,[Company]
        ,[Exchange]
        ,[OperatingArea]
        ,[State]
        ,[Engineer]
        ,[ProjectOwner]
        ,[ApprovalDate]
        ,[EstimatedStartDate]
        ,[EstimatedCompleteDate]
        ,[ActualStartDate]
        ,[ReadyForServiceDate]
        ,[TentativeCloseDate]
        ,[CloseDate]
        ,[AuthorizedDirect]
        ,[AuthorizedIndirect]
        ,[AuthorizedTotal]
        ,[PriorYearsSpendDirect]
        ,[PriorYearsSpendIndirect]
        ,[PriorYearsSpendTotal]
        ,[SpendingForecast]
        ,[JanuaryDirect]
        ,[JanuaryIndirect]
        ,[FebruaryDirect]
        ,[FebruaryIndirect]
        ,[MarchDirect]
        ,[MarchIndirect]
        ,[AprilDirect]
        ,[AprilIndirect]
        ,[MayDirect]
        ,[MayIndirect]
        ,[JuneDirect]
        ,[JuneIndirect]
        ,[JulyDirect]
        ,[JulyIndirect]
        ,[AugustDirect]
        ,[AugustIndirect]
        ,[SeptemberDirect]
        ,[SeptemberIndirect]
        ,[OctoberDirect]
        ,[OctoberIndirect]
        ,[NovemberDirect]
        ,[NovemberIndirect]
        ,[DecemberDirect]
        ,[DecemberIndirect]
        ,[GrossAddsDirect]
        ,[GrossAddsIndirect]
        ,[GrossAddsTotal]
        ,[CIACSpend]
        ,[FutureYearsSpendInfinium]
        ,[FutureYearsSpend]
        ,[SpendingNotNeededDirect]
        ,[SpendingNotNeededIndirect]
        ,[SpendingNotNeeded]
        ,[RemainderToSpendDirect]
        ,[RemainderToSpendIndirect]
        ,[RemainderToSpend]
        ,[AdditionalDollarsNeeded]
        ,[CIACBudget]
        ,[AnalystNotes]
        ,[SubprojectStatus]
        ,[VarassetStatus]
        ,[VarassetStatusDate]
        ,[VarassetClosingIssue]
        ,[VarassetScheduledFinishDate]
        ,[CarryIn]
        ,[SentToClosing]
	)
    select
        [ProjectNumber]
        ,[SubprojectNumber]
        ,[ProjectSubNumber]
        ,[BudgetLineNumber]
        ,[BudgetLineName]
        ,[ClassOfPlant]
        ,[LinkCode]
        ,[BudgetCategory]
        ,[FinanceCategory]
        ,[JustificationCode]
        ,[FunctionalGroup]
        ,[ProjectDescription]
        ,[Billable]
        ,[ProjectStatusCode]
        ,[ApprovalCode]
        ,[ProjectType]
        ,[Company]
        ,[Exchange]
        ,[OperatingArea]
        ,[State]
        ,[Engineer]
        ,[ProjectOwner]
        ,[ApprovalDate]
        ,[EstimatedStartDate]
        ,[EstimatedCompleteDate]
        ,[ActualStartDate]
        ,[ReadyForServiceDate]
        ,[TentativeCloseDate]
        ,[CloseDate]
        ,[AuthorizedDirect]
        ,[AuthorizedIndirect]
        ,[AuthorizedTotal]
        ,[PriorYearsSpendDirect]
        ,[PriorYearsSpendIndirect]
        ,[PriorYearsSpendTotal]
        ,[SpendingForecast]
        ,[JanuaryDirect]
        ,[JanuaryIndirect]
        ,[FebruaryDirect]
        ,[FebruaryIndirect]
        ,[MarchDirect]
        ,[MarchIndirect]
        ,[AprilDirect]
        ,[AprilIndirect]
        ,[MayDirect]
        ,[MayIndirect]
        ,[JuneDirect]
        ,[JuneIndirect]
        ,[JulyDirect]
        ,[JulyIndirect]
        ,[AugustDirect]
        ,[AugustIndirect]
        ,[SeptemberDirect]
        ,[SeptemberIndirect]
        ,[OctoberDirect]
        ,[OctoberIndirect]
        ,[NovemberDirect]
        ,[NovemberIndirect]
        ,[DecemberDirect]
        ,[DecemberIndirect]
        ,[GrossAddsDirect]
        ,[GrossAddsIndirect]
        ,[GrossAddsTotal]
        ,[CIACSpend]
        ,[FutureYearsSpendInfinium]
        ,[FutureYearsSpend]
        ,[SpendingNotNeededDirect]
        ,[SpendingNotNeededIndirect]
        ,[SpendingNotNeeded]
        ,[RemainderToSpendDirect]
        ,[RemainderToSpendIndirect]
        ,[RemainderToSpend]
        ,[AdditionalDollarsNeeded]
        ,[CIACBudget]
        ,[AnalystNotes]
        ,[SubprojectStatus]
        ,[VarassetStatus]
        ,[VarassetStatusDate]
        ,[VarassetClosingIssue]
        ,[VarassetScheduledFinishDate]
        ,[CarryIn]
        ,[SentToClosing]
from forecast.ForecastExport
update history.forecastexport
set [ProductionDate] = getutcdate(),
productiondatetime = cast(getutcdate() as datetime)
where [ProductionDate] is null


--WITH CTE AS
--(
--SELECT *,ROW_NUMBER() OVER (PARTITION BY projectnumber ORDER BY projectnumber) AS RN
--FROM CapitalManagementProduction.history.ForecastExport
--)

--DELETE FROM CTE WHERE RN<>1



UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_CreateForecastExport P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_CreateForecastExport

----------------------------------------------------------------------------------------------------------



COMMIT TRANSACTION
END TRY
BEGIN CATCH
IF @@trancount > 0 ROLLBACK TRANSACTION
EXEC usp_error_handler
RETURN 55555
END CATCH