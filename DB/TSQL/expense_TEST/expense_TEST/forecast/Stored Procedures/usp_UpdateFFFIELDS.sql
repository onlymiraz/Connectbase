-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateFFFIELDS]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateFFFIELDS
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateFFFIELDS]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateFFFIELDS
FROM [LOG].[Tracker]



		DECLARE @t project_fields_tbltype

		-- Insert projects into temp table
		INSERT INTO @t
		SELECT
			LTRIM(RTRIM(FF.[ProjectNumber])),
			LTRIM(RTRIM(FF.[SubprojectNumber])),
			LTRIM(RTRIM(BL.[BudgetLineNumber])),
			LTRIM(RTRIM(FF.[ClassOfPlant])),
			LTRIM(RTRIM(FF.[LinkCode])) AS [LinkCode],
			LTRIM(RTRIM(FF.[JustificationCode])),
			LTRIM(RTRIM(FF.[FunctionalGroup])),
			LTRIM(RTRIM(FF.[ProjectDescription])),
			LTRIM(RTRIM(FF.[ProjectStatusCode])),
			LTRIM(RTRIM(FF.[ApprovalCode])) AS [ApprovalCode],
			LTRIM(RTRIM(FF.[ProjectType])),
			LTRIM(RTRIM(FF.[Billable])),
			LTRIM(RTRIM(FF.[Company])),
			LTRIM(RTRIM(E.[ExchangeName])),
			LTRIM(RTRIM(FF.[State])),
			LTRIM(RTRIM(FF.[OperatingArea])),
			LTRIM(RTRIM(FF.[Engineer])),
			LTRIM(RTRIM(FF.[ProjectOwner])),
			IIF(FF.[ApprovalDate] = 0, NULL, CONVERT(Date, IIF(LEN(FF.[ApprovalDate]) = 6, SUBSTRING(LTRIM(STR(FF.[ApprovalDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[ApprovalDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FF.[ApprovalDate])), 1, 2), SUBSTRING(LTRIM(STR(FF.[ApprovalDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[ApprovalDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[ApprovalDate])), 2, 2)), 0)) AS [ApprovalDate],
			IIF(FF.[EstimatedStartDate] = 0, NULL, CONVERT(Date, IIF(LEN(FF.[EstimatedStartDate]) = 6, SUBSTRING(LTRIM(STR(FF.[EstimatedStartDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[EstimatedStartDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FF.[EstimatedStartDate])), 1, 2), SUBSTRING(LTRIM(STR(FF.[EstimatedStartDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[EstimatedStartDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[EstimatedStartDate])), 2, 2)), 0)) AS [EstimatedStartDate],
			IIF(FF.[EstimatedCompleteDate] = 0, NULL, CONVERT(Date, IIF(LEN(FF.[EstimatedCompleteDate]) = 6, SUBSTRING(LTRIM(STR(FF.[EstimatedCompleteDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[EstimatedCompleteDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FF.[EstimatedCompleteDate])), 1, 2), SUBSTRING(LTRIM(STR(FF.[EstimatedCompleteDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[EstimatedCompleteDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[EstimatedCompleteDate])), 2, 2)), 0)) AS [EstimatedCompleteDate],
			IIF(FF.[ActualStartDate] = 0, NULL, CONVERT(Date, IIF(LEN(FF.[ActualStartDate]) = 6, SUBSTRING(LTRIM(STR(FF.[ActualStartDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[ActualStartDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FF.[ActualStartDate])), 1, 2), SUBSTRING(LTRIM(STR(FF.[ActualStartDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[ActualStartDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[ActualStartDate])), 2, 2)), 0)) AS [ActualStartDate],
			IIF(FF.[ReadyForServiceDate] = 0, NULL, CONVERT(Date, IIF(LEN(FF.[ReadyForServiceDate]) = 6, SUBSTRING(LTRIM(STR(FF.[ReadyForServiceDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[ReadyForServiceDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FF.[ReadyForServiceDate])), 1, 2), SUBSTRING(LTRIM(STR(FF.[ReadyForServiceDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[ReadyForServiceDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[ReadyForServiceDate])), 2, 2)), 0)) AS [ReadyForServiceDate],
			IIF(FF.[TentativeCloseDate] = 0, NULL, CONVERT(Date, IIF(LEN(FF.[TentativeCloseDate]) = 6, SUBSTRING(LTRIM(STR(FF.[TentativeCloseDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[TentativeCloseDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FF.[TentativeCloseDate])), 1, 2), SUBSTRING(LTRIM(STR(FF.[TentativeCloseDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[TentativeCloseDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[TentativeCloseDate])), 2, 2)), 0)) AS [TentativeCloseDate],
			IIF(FF.[CloseDate] = 0, NULL, CONVERT(Date, IIF(LEN(FF.[CloseDate]) = 6, SUBSTRING(LTRIM(STR(FF.[CloseDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[CloseDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FF.[CloseDate])), 1, 2), SUBSTRING(LTRIM(STR(FF.[CloseDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[CloseDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FF.[CloseDate])), 2, 2)), 0)) AS [CloseDate]
		FROM [dbo].[FFFIELDS] AS FF LEFT JOIN forecast.[Exchange] AS E ON (FF.[ExchangeNumber] = E.[ExchangeNumber])
			 LEFT JOIN [dbo].[BUDGETLINE] AS BL ON FF.[ProjectNumber] = BL.[ProjectNumber] AND FF.[SubprojectNumber] = BL.[SubprojectNumber]

		-- Update projects from temp table
		UPDATE P
		SET P.[ProjectDescription] = [@t].[ProjectDescription],
			P.[ClassOfPlant] = [@t].[ClassOfPlant], 
			P.[LinkCode] = IIF([@t].[LinkCode] NOT LIKE '[ ]%', [@t].[LinkCode], NULL),
			P.[JustificationCode] = [@t].[JustificationCode], 
			P.[FunctionalGroup] = [@t].[FunctionalGroup], 
			P.[Billable] = [@t].[Billable], 
			P.[ApprovalCode] = IIF([@t].[ApprovalCode] NOT LIKE '[ ]%', [@t].[ApprovalCode], NULL), 
			P.[ProjectType] = [@t].[ProjectType], 
			P.[Company] = [@t].[Company], 
			P.[ExchangeName] = [@t].[ExchangeName], 
			P.[OperatingArea] = [@t].[OperatingArea], 
			P.[State] = [@t].[State], 
			P.[Engineer] = [@t].[Engineer],
			P.[ProjectOwner] = [@t].[ProjectOwner]
		FROM [forecast].[Project] AS P INNER JOIN @t ON (P.[ProjectNumber] = [@t].[ProjectNumber])

		UPDATE S
		SET	S.[BudgetLineNumber] = [@t].[BudgetLineNumber], 
			S.[ProjectStatusCode] = [@t].[ProjectStatusCode], 
			S.[ApprovalDate] = [@t].[ApprovalDate], 
			S.[EstimatedStartDate] = [@t].[EstimatedStartDate], 
			S.[EstimatedCompleteDate] = [@t].[EstimatedCompleteDate], 
			S.[ActualStartDate] = [@t].[ActualStartDate], 
			S.[ReadyForServiceDate] = [@t].[ReadyForServiceDate], 
			S.[TentativeCloseDate] = [@t].[TentativeCloseDate], 
			S.[CloseDate] = [@t].[CloseDate],
			S.[CarryIn] = IIF(S.[CarryIn] IS NOT NULL, S.[CarryIn], IIF([@t].[ApprovalDate] IS NULL, IIF([@t].[ProjectStatusCode] <> 'SP', 0, 1), IIF([@t].[ApprovalDate] > '20220101', 0, 1)))
		FROM [forecast].[Subproject] AS S INNER JOIN @t ON (S.[ProjectNumber] = [@t].[ProjectNumber] AND S.[SubprojectNumber] = [@t].[SubprojectNumber])

		-- Update carry-in status for subproject 4 if different from subproject 1
		UPDATE S
		SET S.CarryIn = SS.CarryIn
		FROM forecast.Subproject AS S INNER JOIN forecast.Subproject AS SS ON S.ProjectNumber = SS.ProjectNumber
		WHERE S.SubprojectNumber = '4' AND SS.SubprojectNumber = '1' AND S.CarryIn != SS.CarryIn

		-- Delete projects not on FFFIELDS query
		DELETE FROM forecast.Subproject
		WHERE (ProjectNumber * 10 + SubprojectNumber) IN (
		SELECT (S.ProjectNumber * 10 + S.SubprojectNumber)
		FROM forecast.Subproject S LEFT JOIN dbo.FFFIELDS F ON S.ProjectNumber = F.ProjectNumber AND S.SubprojectNumber = F.SubprojectNumber
		WHERE F.ProjectNumber IS NULL AND F.SubprojectNumber IS NULL)


UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateFFFIELDS P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateFFFIELDS


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH