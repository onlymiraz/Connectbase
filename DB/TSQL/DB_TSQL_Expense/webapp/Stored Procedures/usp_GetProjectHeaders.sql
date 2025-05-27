-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [webapp].[usp_GetProjectHeaders]
	@budget_category_id int,
	@sub_budget_category_id int,
	@project_status_code_id int,
	@subproject_status_id int
AS
	SET NOCOUNT ON
BEGIN TRY
	SELECT P.ProjectNumber, S.SubprojectNumber, P.ProjectDescription, IIF(P.BudgetCategoryID IS NULL, JBC.BudgetCategory, PBC.BudgetCategory) AS BudgetCategory, SBC.SubBudgetCategory, P.ApprovalCode, PSC.ProjectStatusCode, STS.SubprojectStatus
	FROM forecast.Project AS P LEFT JOIN forecast.Subproject AS S ON P.ProjectNumber = S.ProjectNumber
		LEFT JOIN forecast.JustificationCode AS J ON P.JustificationCode = J.JustificationCode
		LEFT JOIN forecast.BudgetCategory AS JBC ON J.BudgetCategoryID = JBC.ID
		LEFT JOIN forecast.BudgetCategory AS PBC ON P.BudgetCategoryID = PBC.ID
		LEFT JOIN forecast.SubBudgetCategory AS SBC ON P.SubBudgetCategoryID = SBC.ID
		LEFT JOIN forecast.ProjectStatusCode AS PSC ON S.ProjectStatusCodeID = PSC.ID
		LEFT JOIN forecast.SubprojectStatus AS STS ON S.SubprojectStatusID = STS.ID
	WHERE (@budget_category_id IS NULL OR (P.BudgetCategoryID IS NOT NULL AND P.BudgetCategoryID = @budget_category_id) OR (P.BudgetCategoryID IS NULL AND J.BudgetCategoryID = @budget_category_id)) AND
		  (@sub_budget_category_id IS NULL OR P.SubBudgetCategoryID = @sub_budget_category_id) AND
		  (@project_status_code_id IS NULL OR S.ProjectStatusCodeID = @project_status_code_id) AND 
		  (@subproject_status_id IS NULL OR S.SubprojectStatusID = @subproject_status_id)
END TRY
BEGIN CATCH
	EXEC usp_error_handler
	RETURN 55555
END CATCH