-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [webapp].[usp_GetProjectDetail]
	-- Add the parameters for the stored procedure here
	@project_number int,
	@subproject_number smallint
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	SELECT P.[ProjectNumber],
		   S.[SubprojectNumber],
		   S.[BudgetLineNumber],
		   P.[ClassOfPlant],
		   P.[LinkCode],
		   P.[JustificationCode],
		   B.[BudgetCategory],
		   SB.[SubBudgetCategory],
		   P.[FunctionalGroup],
		   P.[ProjectDescription],
		   P.[Billable],
		   PSC.[ProjectStatusCode],
		   P.[ApprovalCode],
		   P.[ProjectType],
		   P.[Company],
		   P.[ExchangeName],
		   P.[OperatingArea],
		   P.[State],
		   P.[Engineer],
		   P.[ProjectOwner],
		   S.[ApprovalDate],
		   S.[EstimatedStartDate],
		   S.[EstimatedCompleteDate],
		   S.[ActualStartDate],
		   S.[ReadyForServiceDate],
		   S.[TentativeCloseDate],
		   S.[CloseDate],
		   S.[SubprojectStatusID],
		   STS.[SubprojectStatus],
		   S.[CarryIn],
		   S.[SentToClosing]
	FROM [forecast].[Project] AS P LEFT JOIN [forecast].[Subproject] AS S ON P.ProjectNumber = S.ProjectNumber
		LEFT JOIN forecast.JustificationCode AS J ON P.JustificationCode = J.JustificationCode
		LEFT JOIN forecast.BudgetCategory AS B ON J.BudgetCategoryID = B.ID
		LEFT JOIN forecast.SubBudgetCategory SB ON P.SubBudgetCategoryID = SB.ID
		LEFT JOIN forecast.ProjectStatusCode AS PSC ON S.ProjectStatusCodeID = PSC.ID
		LEFT JOIN forecast.SubprojectStatus AS STS ON S.SubprojectStatusID = STS.ID
	WHERE S.ProjectNumber = @project_number AND S.SubprojectNumber = @subproject_number
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(2048) = error_message()
	RAISERROR (@msg, 16, 1)
	RETURN 55555
END CATCH
