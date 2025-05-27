-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_ImportSubprojects]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
		
		DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ImportSubprojects
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_ImportSubprojects]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_ImportSubprojects
FROM [LOG].[Tracker]

		
		
		-- Update or insert subproject table
		MERGE forecast.Subproject AS S
		USING dbo.ForecastImport AS F
		ON (S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber)
		WHEN MATCHED THEN
			UPDATE
			SET S.[BudgetLineNumber] = F.[BudgetLineNumber],
				S.[ProjectStatusCode] = F.[ProjectStatusCode],
				S.[ApprovalDate] = F.[ApprovalDate],
				S.[EstimatedStartDate] = F.[EstimatedStartDate],
				S.[EstimatedCompleteDate] = F.[EstimatedCompleteDate],
				S.[ActualStartDate] = F.[ActualStartDate],
				S.[ReadyForServiceDate] = F.[ReadyForServiceDate],
				S.[TentativeCloseDate] = F.[TentativeCloseDate],
				S.[CloseDate] = F.[CloseDate],
				S.[SubprojectStatus] = F.[SubprojectStatus],
				S.[CarryIn] = IIF(F.[CarryIn] = '2021', 0, 1),
				S.[SentToClosing] = F.[SentToClosing]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, BudgetLineNumber, ProjectStatusCode, ApprovalDate, EstimatedStartDate, EstimatedCompleteDate, 
					ActualStartDate, ReadyForServiceDate, TentativeCloseDate, CloseDate, SubprojectStatus, CarryIn, SentToClosing)
			VALUES (F.ProjectNumber, F.SubprojectNumber, F.BudgetLineNumber, F.ProjectStatusCode, F.ApprovalDate, F.EstimatedStartDate, F.EstimatedCompleteDate,
					F.ActualStartDate, F.ReadyForServiceDate, F.TentativeCloseDate, F.CloseDate, F.SubprojectStatus, IIF(F.[CarryIn] = '2021', 0, 1), F.SentToClosing);
		
		-- Update or insert subproject authorized table
		MERGE forecast.SubprojectAuthorized AS S
		USING dbo.ForecastImport AS F
		ON (S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber)
		WHEN MATCHED THEN
			UPDATE
			SET S.Direct = F.[AuthorizedDirect],
				S.Indirect = F.[AuthorizedIndirect]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, Direct, Indirect)
			VALUES (F.ProjectNumber, F.SubprojectNumber, F.AuthorizedDirect, F.AuthorizedIndirect);
			
		-- Update or insert subproject CIAC table
		MERGE forecast.SubprojectCIAC AS S
		USING dbo.ForecastImport AS F
		ON (S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber)
		WHEN MATCHED THEN
			UPDATE
			SET S.Budget = F.[CIACBudget],
				S.Spend = F.[AllCIAC]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, Budget, Spend)
			VALUES (F.ProjectNumber, F.SubprojectNumber, F.AllCIAC, F.CIACBudget);

		-- Update or insert subproject financial table
		MERGE forecast.SubprojectFinancial AS S
		USING dbo.ForecastImport AS F
		ON (S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber)
		WHEN MATCHED THEN
			UPDATE
			SET S.[SpendingNotNeeded] = F.[SpendingNotNeeded],
				S.[AdditionalDollarsNeeded] = F.[AdditionalDollarsNeeded]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, SpendingNotNeeded, AdditionalDollarsNeeded)
			VALUES (F.ProjectNumber, F.SubprojectNumber, F.SpendingNotNeeded, F.AdditionalDollarsNeeded);

		-- Update or insert subproject future year table
		MERGE forecast.SubprojectFutureYear AS S
		USING dbo.ForecastImport AS F
		ON (S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber)
		WHEN MATCHED THEN
			UPDATE
			SET S.SpendInfinium = F.[FutureYearsSpendingInfinium],
				S.Spend = F.[FutureYearsSpending]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, SpendInfinium, Spend)
			VALUES (F.ProjectNumber, F.SubprojectNumber, F.FutureYearsSpendingInfinium, F.FutureYearsSpending);

		-- Update or insert subproject prior year table
		MERGE forecast.SubprojectPriorYear3 AS S
		USING dbo.ForecastImport AS F
		ON (S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber)
		WHEN MATCHED THEN
			UPDATE
			SET S.Spend = F.[PriorYearsSpent]
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, Spend)
			VALUES (F.ProjectNumber, F.SubprojectNumber, F.PriorYearsSpent);

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_ImportSubprojects P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ImportSubprojects



	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH