-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_ImportSubprojects_New]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
		-- Update or insert subproject table
		MERGE forecast.Subproject AS S
		USING dbo.ForecastImportMissingLines AS F
		ON (S.ProjectNumber = F.Proj AND S.SubprojectNumber = F.SubNum)
		WHEN MATCHED THEN
			UPDATE
			SET S.[BudgetLineNumber] = F.[BudgetLineNum],
				S.[ProjectStatusCode] = F.[ProjStatus],
				S.[ApprovalDate] = F.[ApprCode],
				S.[EstimatedStartDate] = F.[EstStartDate],
				S.[EstimatedCompleteDate] = F.[EstCompDate],
				S.[ActualStartDate] = F.[ActStartDate],
				S.[ReadyForServiceDate] = F.[RdyForSvcDate],
				S.[TentativeCloseDate] = F.[TentCloseDate],
				S.[CloseDate] = F.[CloseDate],
				S.[SubprojectStatus] = F.[CurrentProjectStatus],
				S.[CarryIn] = IIF(F.[2020orCarryIn] = '2019', 0, 1),
				S.[SentToClosing] = F.[SentToClosing]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, BudgetLineNumber, ProjectStatusCode, ApprovalDate, EstimatedStartDate, EstimatedCompleteDate, 
					ActualStartDate, ReadyForServiceDate, TentativeCloseDate, CloseDate, SubprojectStatus, CarryIn, SentToClosing)
			VALUES (F.Proj, F.Subnum, F.BudgetLineNum, F.ProjStatus, F.ApprovalDate, F.EstStartDate, F.EstCompDate,
					F.Actstartdate, F.RdyForSvcDate, F.TentCloseDate, F.CloseDate, F.currentprojectStatus, IIF(F.[2020orCarryIn] = '2019', 0, 1), F.SentToClosing);
		
		-- Update or insert subproject authorized table
		MERGE forecast.SubprojectAuthorized AS S
		USING dbo.ForecastImportMissingLines AS F
		ON (S.ProjectNumber = F.Proj AND S.SubprojectNumber = F.Subnum)
		WHEN MATCHED THEN
			UPDATE
			SET S.Direct = F.[CurrentProjectAuthorizedDirect],
				S.Indirect = F.[CurrentProjectAuthorizedinDirect]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, Direct, Indirect)
			VALUES (F.Proj, F.subnum, F.CurrentProjectAuthorizedDirect, F.CurrentProjectAuthorizedinDirect);
			
		-- Update or insert subproject CIAC table
		MERGE forecast.SubprojectCIAC AS S
		USING dbo.ForecastImportMissingLines AS F
		ON (S.ProjectNumber = F.Proj AND S.SubprojectNumber = F.subnum)
		WHEN MATCHED THEN
			UPDATE
			SET S.Budget = F.[CIACBudget],
				S.Spend = F.[AllCIAC]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, Budget, Spend)
			VALUES (F.Proj, F.subnum, F.AllCIAC, F.CIACBudget);

		-- Update or insert subproject financial table
		MERGE forecast.SubprojectFinancial AS S
		USING dbo.ForecastImportMissingLines AS F
		ON (S.ProjectNumber = F.proj AND S.SubprojectNumber = F.subnum)
		WHEN MATCHED THEN
			UPDATE
			SET S.[SpendingNotNeeded] = F.[SpendingNotNeeded],
				S.[AdditionalDollarsNeeded] = F.[AdditionalDollarsNeeded]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, SpendingNotNeeded, AdditionalDollarsNeeded)
			VALUES (F.proj, F.subnum, F.SpendingNotNeeded, F.AdditionalDollarsNeeded);

		-- Update or insert subproject future year table
		MERGE forecast.SubprojectFutureYear AS S
		USING dbo.ForecastImportMissingLines AS F
		ON (S.ProjectNumber = F.proj AND S.SubprojectNumber = F.subnum)
		WHEN MATCHED THEN
			UPDATE
			SET S.SpendInfinium = F.[FutureYearsSpending-Infinium],
				S.Spend = F.[FutureYearsSpending]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, SpendInfinium, Spend)
			VALUES (F.proj, F.subnum, F.[FutureYearsSpending-Infinium], F.FutureYearsSpending);

		-- Update or insert subproject prior year table
		MERGE forecast.SubprojectPriorYear AS S
		USING dbo.ForecastImportMissingLines AS F
		ON (S.ProjectNumber = F.proj AND S.SubprojectNumber = F.subnum)
		WHEN MATCHED THEN
			UPDATE
			SET S.Spend = F.[TotalPriorYearsSpending]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, Spend)
			VALUES (F.proj, F.subnum, F.TotalPriorYearsSpending);
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH