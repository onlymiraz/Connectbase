-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdateAuthorized]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateAuthorized
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateAuthorized]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateAuthorized
FROM [LOG].[Tracker]



		UPDATE DBO.AUTHORIZED
		SET CostCode=111
		WHERE CostCode = 997

		-- Insert new CAP AND COR projects and subprojects
		DECLARE @PROJ TABLE ([ProjectNumber] int, [SubprojectNumber] smallint, [CostCode] smallint, [Dollars] float)
		DECLARE @DA TABLE ([ProjectNumber] int, [SubprojectNumber] smallint, [DirectDollars] float)
		DECLARE @IA TABLE ([ProjectNumber] int, [SubprojectNumber] smallint, [IndirectDollars] float)

		INSERT INTO @PROJ ([ProjectNumber], [SubprojectNumber], [CostCode], [Dollars])
		SELECT [ProjectNumber], [SubprojectNumber], [CostCode], [Dollars]
		FROM (
			SELECT [ProjectNumber], [SubprojectNumber], [CostCode], SUM([BudgetDollars]) AS [Dollars]
			FROM [AUTHORIZED]
			GROUP BY [ProjectNumber], [SubprojectNumber], [CostCode]
		) AS A

		INSERT INTO @DA ([ProjectNumber], [SubprojectNumber], [DirectDollars])
		SELECT [ProjectNumber], [SubprojectNumber], SUM([Dollars])
		FROM @PROJ
		WHERE [CostCode] NOT LIKE '9%'
		GROUP BY [ProjectNumber], [SubprojectNumber]

		INSERT INTO @IA ([ProjectNumber], [SubprojectNumber], [IndirectDollars])
		SELECT [ProjectNumber], [SubprojectNumber], SUM([Dollars])
		FROM @PROJ
		WHERE [CostCode] LIKE '9%'
		GROUP BY [ProjectNumber], [SubprojectNumber]

		UPDATE F
		SET F.Direct = ISNULL(ROUND([@DA].[DirectDollars], 2), 0)
		FROM [forecast].[SubprojectAuthorized] AS F INNER JOIN forecast.Subproject AS S ON F.ProjectNumber = S.ProjectNumber AND F.SubprojectNumber = S.SubprojectNumber
			 LEFT JOIN @DA ON (F.[ProjectNumber] = [@DA].[ProjectNumber] AND F.[SubprojectNumber] = [@DA].[SubprojectNumber])
			 --LEFT JOIN forecast.ProjectStatusCode AS PSC ON S.ProjectStatusCodeID = PSC.ID
		WHERE S.ProjectStatusCode NOT IN ('CL', 'CX')

		UPDATE F
		SET F.Indirect = ISNULL(ROUND([@IA].[IndirectDollars], 2), 0)
		FROM [forecast].[SubprojectAuthorized] AS F INNER JOIN forecast.Subproject AS S ON F.ProjectNumber = S.ProjectNumber AND F.SubprojectNumber = S.SubprojectNumber
			 LEFT JOIN @IA ON (F.[ProjectNumber] = [@IA].[ProjectNumber] AND F.[SubprojectNumber] = [@IA].[SubprojectNumber])
			 --LEFT JOIN forecast.ProjectStatusCode AS PSC ON S.ProjectStatusCodeID = PSC.ID
		WHERE S.ProjectStatusCode NOT IN ('CL', 'CX')

		UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateAuthorized P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateAuthorized

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH