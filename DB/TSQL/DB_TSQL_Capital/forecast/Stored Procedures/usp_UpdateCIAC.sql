-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateCIAC]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateCIAC
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateCIAC]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateCIAC
FROM [LOG].[Tracker]



DECLARE @t TABLE ([ProjectNumber] int, [SubprojectNumber] smallint, [BudgetDollars] float, [SpentDollars] float)

INSERT INTO @t ([ProjectNumber], [SubprojectNumber], [BudgetDollars], [SpentDollars])
SELECT [ProjectNumber], [SubprojectNumber], [CIAC].[BudgetDollars], [CIAC].[SpentDollars]
FROM (
	SELECT [ProjectNumber], [SubprojectNumber], Sum([BudgetDollars]) AS [BudgetDollars], Sum([SpentDollars]) AS [SpentDollars]
	FROM [CIACFORFF]
	GROUP BY [ProjectNumber], [SubprojectNumber]
) AS CIAC

UPDATE F
SET F.Spend = ISNULL(ROUND([@t].[SpentDollars], 2), 0),
	F.Budget = ISNULL(ROUND([@t].[BudgetDollars], 2), 0)
FROM [forecast].SubprojectCIAC AS F INNER JOIN forecast.Subproject AS S ON F.ProjectNumber = S.ProjectNumber AND F.SubprojectNumber = S.SubprojectNumber
		LEFT JOIN @t ON (S.[ProjectNumber] = [@t].[ProjectNumber] AND S.[SubprojectNumber] = [@t].[SubprojectNumber])
		--LEFT JOIN forecast.ProjectStatusCode AS PSC ON S.ProjectStatusCodeID = PSC.ID
WHERE S.ProjectStatusCode NOT IN ('CL', 'CX')

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateCIAC P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateCIAC


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
