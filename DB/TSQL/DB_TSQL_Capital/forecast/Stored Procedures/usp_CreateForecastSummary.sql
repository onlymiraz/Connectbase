
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_CreateForecastSummary]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @summary_date date = GETDATE()

		INSERT INTO forecast.SummaryTemp
		SELECT @summary_date AS SummaryDate,
				S.ProjectNumber AS ProjectNumber,
				S.SubprojectNumber AS SubprojectNumber,
				((S.ProjectNumber * 10) + S.SubprojectNumber) AS ProjectSubNumber,
				S.BudgetLineNumber AS BudgetLineNumber,
				B.BudgetLineName AS BudgetLineName,
				P.ClassOfPlant AS ClassOfPlant,
				P.LinkCode AS LinkCode,
				P.JustificationCode AS JustificationCode,
				IIF(P.SubBudgetCategoryID IS NOT NULL, IIF(SBC.Overwrite = 1, SBC.SubBudgetCategory, PBC.BudgetCategory + ' ' + IIF(SBC.Separator IS NOT NULL, SBC.Separator + ' ', '') + SBC.SubBudgetCategory), IIF(P.BudgetCategoryID IS NOT NULL, PBC.BudgetCategory, JBC.BudgetCategory))
					+ IIF(P.SubBudgetCategoryID IS NOT NULL, IIF(SBC.HasCarryIn = 1, IIF(S.CarryIn = 1, ' Carry-In', ''), ''), IIF(S.CarryIn = 1, ' Carry-In', '')) AS BudgetCategory,
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
				PY.Spend AS PriorYearsSpend,
				0.0 AS ProjectVariance,
				0.0 AS PercentOverUnder,
				0.0 AS SpendingForecast,
				GD.January AS JanuaryDirect,
				GI.January AS JanuaryIndirect,
				GD.February AS [FebruaryDirect],
				GI.February AS [FebruaryIndirect],
				GD.March AS [MarchDirect],
				GI.March AS [MarchIndirect],
				GD.April AS [AprilDirect],
				GI.April AS [AprilIndirect],
				GD.May AS [MayDirect],
				GI.May AS [MayIndirect],
				GD.June AS [JuneDirect],
				GI.June AS [JuneIndirect],
				GD.July AS [JulyDirect],
				GI.July AS [JulyIndirect],
				GD.August AS [AugustDirect],
				GI.August AS [AugustIndirect],
				GD.September AS [SeptemberDirect],
				GI.September AS [SeptemberIndirect],
				GD.October AS [OctoberDirect],
				GI.October AS [OctoberIndirect],
				GD.November AS [NovemberDirect],
				GI.November AS [NovemberIndirect],
				GD.December AS [DecemberDirect],
				GI.December AS [DecemberIndirect],
				(GD.January + GD.February + GD.March + GD.April + GD.May + GD.June + GD.July + GD.August + GD.September + GD.October + GD.November + GD.December) AS GrossAddsDirect,
				(GI.January + GI.February + GI.March + GI.April + GI.May + GI.June + GI.July + GI.August + GI.September + GI.October + GI.November + GI.December) AS GrossAddsIndirect,
				(GD.January + GD.February + GD.March + GD.April + GD.May + GD.June + GD.July + GD.August + GD.September + GD.October + GD.November + GD.December +
				GI.January + GI.February + GI.March + GI.April + GI.May + GI.June + GI.July + GI.August + GI.September + GI.October + GI.November + GI.December) AS GrossAddsTotal,
				CIAC.Budget AS [CIACBudget],
				CIAC.Spend AS [CIACSpend],
				FY.SpendInfinium AS [FutureYearsSpendInfinium],
				FY.Spend AS [FutureYearsSpend],
				F.SpendingNotNeeded AS [SpendingNotNeeded],
				0.0 AS [RemainderToSpend],
				F.AdditionalDollarsNeeded AS [AdditionalDollarsNeeded],
				0.0 AS [Q1Direct],
				0.0 AS [Q1Indirect],
				0.0 AS [Q2Direct],
				0.0 AS [Q2Indirect],
				0.0 AS [Q3Direct],
				0.0 AS [Q3Indirect],
				0.0 AS [Q4Direct],
				0.0 AS [Q4Indirect],
				0.0 AS [QuarterlyDirect],
				0.0 AS [QuarterlyIndirect],
				0.0 AS [QuarterlyTotal],
				'' AS Notes,
				S.SubprojectStatus AS SubprojectStatus,
				S.CarryIn AS [CarryIn],
				S.SentToClosing AS [SentToClosing]
		FROM forecast.Project AS P INNER JOIN forecast.Subproject AS S ON P.ProjectNumber = S.ProjectNumber
				LEFT JOIN forecast.BudgetLine AS B ON S.BudgetLineNumber = B.BudgetLineNumber
				LEFT JOIN forecast.GrossAddsDirect AS GD ON S.ProjectNumber = GD.ProjectNumber AND S.SubprojectNumber = GD.SubprojectNumber AND GD.[Year] = YEAR(GETDATE())
				LEFT JOIN forecast.JustificationCode AS JC ON P.JustificationCode = JC.JustificationCode
				LEFT JOIN forecast.BudgetCategory AS JBC ON JC.BudgetCategoryID = JBC.ID
				LEFT JOIN forecast.BudgetCategory AS PBC ON P.BudgetCategoryID = PBC.ID
				LEFT JOIN forecast.SubBudgetCategory AS SBC ON P.SubBudgetCategoryID = SBC.ID
				LEFT JOIN forecast.GrossAddsIndirect AS GI ON S.ProjectNumber = GI.ProjectNumber AND S.SubprojectNumber = GI.SubprojectNumber AND GI.[Year] = YEAR(GETDATE())
				--LEFT JOIN forecast.ProjectStatusCode AS PSC ON S.ProjectStatusCodeID = PSC.ID
				LEFT JOIN forecast.SubprojectAuthorized AS AUTH ON S.ProjectNumber = AUTH.ProjectNumber AND S.SubprojectNumber = AUTH.SubprojectNumber
				LEFT JOIN forecast.SubprojectCIAC AS CIAC ON S.ProjectNumber = CIAC.ProjectNumber AND S.SubprojectNumber = CIAC.SubprojectNumber
				LEFT JOIN forecast.SubprojectFinancial AS F ON S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber
				LEFT JOIN forecast.SubprojectFutureYear AS FY ON S.ProjectNumber = FY.ProjectNumber AND S.SubprojectNumber = FY.SubprojectNumber
				LEFT JOIN forecast.SubprojectPriorYear AS PY ON S.ProjectNumber = PY.ProjectNumber AND S.SubprojectNumber = PY.SubprojectNumber
				--LEFT JOIN forecast.SubprojectStatus AS STS ON S.SubprojectStatusID = STS.ID

		DELETE FROM forecast.SummaryTemp
		WHERE SummaryDate = @summary_date AND ProjectStatusCode IN ('CL', 'CX') AND
			  GrossAddsTotal = 0
			  /*
			  JanuaryDirect = 0 AND JanuaryIndirect = 0 AND
			  FebruaryDirect = 0 AND FebruaryIndirect = 0 AND
			  MarchDirect = 0 AND MarchIndirect = 0 AND
			  AprilDirect = 0 AND AprilIndirect = 0 AND
			  MayDirect = 0 AND MayIndirect = 0 AND
			  JuneDirect = 0 AND JuneIndirect = 0 AND
			  JulyDirect = 0 AND JulyIndirect = 0 AND
			  AugustDirect = 0 AND AugustIndirect = 0 AND
			  SeptemberDirect = 0 AND AugustIndirect = 0 AND
			  OctoberDirect = 0 AND OctoberIndirect = 0 AND
			  NovemberDirect = 0 AND NovemberIndirect = 0 AND
			  DecemberDirect = 0 AND DecemberIndirect = 0
			  */
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
