-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_UpdatePriorYearsSpent]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdatePriorYearsSpent
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdatePriorYearsSpent]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdatePriorYearsSpent
FROM [LOG].[Tracker]



		DECLARE @t TABLE ([ProjectNumber] int, [SubprojectNumber] smallint, [Direct] money, [Indirect] money, [Total] money)

		INSERT INTO @t ([ProjectNumber], [SubprojectNumber], Direct, Indirect, Total)
		SELECT [ProjectNumber], [SubprojectNumber], Direct, Indirect, Total
		FROM (
			SELECT [ProjectNumber], [SubprojectNumber], SUM([Direct]) AS Direct, SUM([Indirect]) AS Indirect, SUM(Total) AS Total
			FROM dbo.PRIORYEAR
			GROUP BY [ProjectNumber], [SubprojectNumber]
		) AS PRYR

		UPDATE S
		SET S.Direct = ISNULL(ROUND([@t].Direct, 2), 0),
			S.Indirect = ISNULL(ROUND([@t].Indirect, 2), 0),
			S.Spend = ISNULL(ROUND([@t].Total, 2), 0)
		FROM [forecast].SubprojectPriorYear3 AS S INNER JOIN [dbo].[NewProjects] AS N ON S.ProjectNumber = N.ProjectNumber AND S.SubprojectNumber = N.SubprojectNumber
			 INNER JOIN @t ON (S.[ProjectNumber] = [@t].[ProjectNumber] AND S.[SubprojectNumber] = [@t].[SubprojectNumber])


UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdatePriorYearsSpent P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdatePriorYearsSpent


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH