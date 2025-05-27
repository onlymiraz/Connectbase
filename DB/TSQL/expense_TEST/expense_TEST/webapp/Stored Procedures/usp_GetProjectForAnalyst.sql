-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [webapp].[usp_GetProjectForAnalyst]
	@project_number int,
	@subproject_number int
AS
	SET NOCOUNT ON;
BEGIN TRY
	SELECT P.ProjectNumber, S.SubprojectNumber, P.ProjectDescription, B.BudgetCategory, SB.SubBudgetCategory, P.ApprovalCode, S.ProjectStatusCode, S.EstimatedCompleteDate, 
			(GD.January + GD.February + GD.March + GD.April + GD.May + GD.June + GD.July + GD.August + GD.September + GD.October + GD.November + GD.December) AS [GrossAddsDirect], 
			(GI.January + GI.February + GI.March + GI.April + GI.May + GI.June + GI.July + GI.August + GI.September + GI.October + GI.November + GI.December) AS [GrossAddsIndirect], 
			S.SubprojectStatus, PY.Spend AS [PriorYearSpend], FY.Spend AS [FutureYearsSpend], F.SpendingNotNeeded, S.ModifiedBy, S.ModifiedDate
	FROM forecast.Project AS P LEFT JOIN forecast.Subproject AS S ON P.ProjectNumber = S.ProjectNumber
		LEFT JOIN forecast.GrossAddsDirect AS GD ON S.ProjectNumber = GD.ProjectNumber AND S.SubprojectNumber = GD.SubprojectNumber
		LEFT JOIN forecast.GrossAddsIndirect AS GI ON S.ProjectNumber = GI.ProjectNumber AND S.SubprojectNumber = GI.SubprojectNumber
		LEFT JOIN forecast.SubprojectFinancial AS F ON S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber
		LEFT JOIN forecast.SubprojectFutureYear AS FY ON S.ProjectNumber = FY.ProjectNumber AND S.SubprojectNumber = FY.SubprojectNumber
		LEFT JOIN forecast.SubprojectPriorYear AS PY ON S.ProjectNumber = PY.ProjectNumber AND S.SubprojectNumber = PY.SubprojectNumber
		LEFT JOIN forecast.JustificationCode AS J ON P.JustificationCode = J.JustificationCode
		LEFT JOIN forecast.BudgetCategory AS B ON J.BudgetCategoryID = B.ID
		LEFT JOIN forecast.SubBudgetCategory AS SB ON P.SubBudgetCategoryID = SB.ID
		--LEFT JOIN forecast.ProjectStatusCode AS PSC ON S.ProjectStatusCodeID = PSC.ID
		--LEFT JOIN forecast.SubprojectStatus AS STS ON S.SubprojectStatusID = STS.ID
	WHERE P.ProjectNumber = @project_number AND (@subproject_number IS NULL OR S.SubprojectNumber = @subproject_number)
END TRY
BEGIN CATCH
	EXEC usp_error_handler
	RETURN 55555
END CATCH