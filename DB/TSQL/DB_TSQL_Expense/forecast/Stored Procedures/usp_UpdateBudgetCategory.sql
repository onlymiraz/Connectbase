-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateBudgetCategory]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateBudgetCategory
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateBudgetCategory]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateBudgetCategory
FROM [LOG].[Tracker]



		-- Update budget category with justification code table
		UPDATE P
		SET P.[BudgetCategoryID] = J.[BudgetCategoryID],
			P.SubBudgetCategoryID = J.SubBudgetCategoryID
		FROM [forecast].[Project] AS P LEFT JOIN [forecast].[JustificationCode] AS J ON P.[JustificationCode] = J.[JustificationCode]

		-- Budget line number and no just code
		UPDATE P
		SET P.[BudgetCategoryID] = C.[BudgetCategoryID],
			P.SubBudgetCategoryID = C.SubBudgetCategoryID
		FROM [forecast].[Project] AS P INNER JOIN [forecast].[Subproject] AS S ON P.[ProjectNumber] = S.[ProjectNumber]
			 INNER JOIN [forecast].[BudgetCategoryCorrection] AS C ON S.[BudgetLineNumber] = C.[BudgetLineNumber]
		WHERE C.[BudgetLineNumber] IS NOT NULL AND C.JustificationCode IS NULL

		-- Budget line number and just code
		UPDATE P
		SET P.[BudgetCategoryID] = C.[BudgetCategoryID],
			P.SubBudgetCategoryID = C.SubBudgetCategoryID
		FROM [forecast].[Project] AS P INNER JOIN [forecast].[Subproject] AS S ON P.[ProjectNumber] = S.[ProjectNumber] 
			 INNER JOIN [forecast].[BudgetCategoryCorrection] AS C ON S.[BudgetLineNumber] = C.[BudgetLineNumber] AND P.JustificationCode = C.JustificationCode
		WHERE C.[BudgetLineNumber] IS NOT NULL AND C.JustificationCode IS NOT NULL
		
		-- Just code and class of plant
		UPDATE P
		SET P.[BudgetCategoryID] = C.[BudgetCategoryID],
			P.SubBudgetCategoryID = C.SubBudgetCategoryID
		FROM [forecast].[Project] AS P INNER JOIN [forecast].[Subproject] AS S ON P.[ProjectNumber] = S.[ProjectNumber] 
			 INNER JOIN [forecast].[BudgetCategoryCorrection] AS C ON P.JustificationCode = C.JustificationCode AND P.ClassOfPlant = C.ClassOfPlant
		WHERE C.JustificationCode IS NOT NULL AND C.ClassOfPlant IS NOT NULL AND C.FunctionalGroup IS NULL
		
		-- Just code, functional group, and class of plant
		UPDATE P
		SET P.[BudgetCategoryID] = C.[BudgetCategoryID],
			P.SubBudgetCategoryID = C.SubBudgetCategoryID
		FROM [forecast].[Project] AS P INNER JOIN [forecast].[Subproject] AS S ON P.[ProjectNumber] = S.[ProjectNumber] 
			 INNER JOIN [forecast].[BudgetCategoryCorrection] AS C ON P.JustificationCode = C.JustificationCode AND P.ClassOfPlant = C.ClassOfPlant AND P.FunctionalGroup = C.FunctionalGroup
		WHERE C.JustificationCode IS NOT NULL AND C.ClassOfPlant IS NOT NULL AND C.FunctionalGroup IS NOT NULL
	
		-- Link code and no just code and no functional group
		UPDATE P
		SET P.[BudgetCategoryID] = C.[BudgetCategoryID],
			P.SubBudgetCategoryID = C.SubBudgetCategoryID
		FROM [forecast].[Project] AS P INNER JOIN [forecast].[BudgetCategoryCorrection] AS C ON P.[LinkCode] = C.[LinkCode]
		WHERE C.[LinkCode] IS NOT NULL AND C.JustificationCode IS NULL AND C.FunctionalGroup IS NULL
	
		-- Link code and just code and no functional group
		UPDATE P
		SET P.[BudgetCategoryID] = C.[BudgetCategoryID],
			P.SubBudgetCategoryID = C.SubBudgetCategoryID
		FROM [forecast].[Project] AS P INNER JOIN [forecast].[BudgetCategoryCorrection] AS C ON P.[LinkCode] = C.[LinkCode] AND P.JustificationCode = C.JustificationCode
		WHERE C.[LinkCode] IS NOT NULL AND C.JustificationCode IS NOT NULL AND C.FunctionalGroup IS NULL
		
		-- Link code and functional group, no just code
		/*
		UPDATE P
		SET P.[BudgetCategoryID] = C.[BudgetCategoryID],
			P.SubBudgetCategoryID = C.SubBudgetCategoryID
		FROM [forecast].[Project] AS P INNER JOIN [forecast].[BudgetCategoryCorrection] AS C ON P.[LinkCode] = C.[LinkCode] AND P.FunctionalGroup = C.FunctionalGroup
		WHERE C.[LinkCode] IS NOT NULL AND C.JustificationCode IS NULL AND C.FunctionalGroup IS NOT NULL
		*/

		-- By project number
		UPDATE P
		SET P.[BudgetCategoryID] = C.[BudgetCategoryID],
			P.SubBudgetCategoryID = C.SubBudgetCategoryID
		FROM [forecast].[Project] AS P INNER JOIN [forecast].[BudgetCategoryCorrection] AS C ON P.ProjectNumber = C.ProjectNumber

		-- Outpost Divestiture Projects
		UPDATE P
		SET P.[BudgetCategoryID] = 25,
			P.SubBudgetCategoryID = NULL
		FROM [forecast].[Project] AS P INNER JOIN [forecast].[Subproject] AS S ON P.[ProjectNumber] = S.[ProjectNumber]
			 INNER JOIN forecast.BudgetLine B ON B.BudgetLineNumber = S.BudgetLineNumber
		WHERE B.BudgetLineName LIKE 'OUTPOST%'


UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateBudgetCategory P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateBudgetCategory

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH