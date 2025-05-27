CREATE PROCEDURE [forecast].[usp_UpdateGrossAdds]
	@year int,
	@start_month int,
	@end_month int
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateGrossAdds
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateGrossAdds]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateGrossAdds
FROM [LOG].[Tracker]


		DECLARE @update_month int
		
		INSERT dbo.NewProjects (ProjectNumber, SubprojectNumber)
		SELECT DISTINCT ProjectNumber, SubprojectNumber
		FROM dbo.GA G
		WHERE NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM forecast.Subproject S WHERE S.ProjectNumber = G.ProjectNumber AND S.SubprojectNumber = G.SubprojectNumber) AND (G.SubprojectNumber = 1 OR G.SubprojectNumber = 4)
			AND NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM dbo.NewProjects N WHERE G.ProjectNumber = N.ProjectNumber AND G.SubprojectNumber = N.SubprojectNumber)

		-- Insert new CAP AND COR projects and subprojects
		INSERT forecast.Project (ProjectNumber)
		SELECT DISTINCT ProjectNumber
		FROM dbo.GA G
		WHERE NOT EXISTS (SELECT ProjectNumber FROM forecast.Project P WHERE P.ProjectNumber = G.ProjectNumber) AND (G.SubprojectNumber = 1 OR G.SubprojectNumber = 4)
		
		INSERT forecast.Subproject (ProjectNumber, SubprojectNumber)
		SELECT DISTINCT ProjectNumber, SubprojectNumber
		FROM dbo.GA G
		WHERE NOT EXISTS (SELECT ProjectNumber, SubprojectNumber FROM forecast.Subproject S WHERE S.ProjectNumber = G.ProjectNumber AND S.SubprojectNumber = G.SubprojectNumber) AND (G.SubprojectNumber = 1 OR G.SubprojectNumber = 4)
	
		DECLARE @t TABLE ([ProjectNumber] int, [SubprojectNumber] smallint, [GAACTY] smallint, [GAACTP] tinyint, [SumOfGARPT$] float)
		DECLARE @u TABLE ([ProjectNumber] int, [SubprojectNumber] smallint, [GAACTY] smallint, [GAACTP] tinyint, [SumOfGARPT$] float)
		DECLARE @curMonth int = @start_month
		
		----New web based job scheduler in SSIS server
		--DECLARE @curMonth int = 1
		--SET @end_month = 12
		
		WHILE @curMonth <= @end_month
		BEGIN
			-- Clear temp tables
			DELETE FROM @t
			DELETE FROM @u

			-- Find sum of direct gross adds
			INSERT INTO  @t ([ProjectNumber], [SubprojectNumber], [GAACTY], [GAACTP], [SumOfGARPT$])
			SELECT R.[ProjectNumber], R.[SubprojectNumber], R.[GAACTY], R.[GAACTP], R.[SumOfGARPT$]
			FROM (
				SELECT [CAP].[ProjectNumber], [CAP].[SubprojectNumber], [CAP].[GAACTY], [CAP].[GAACTP], Sum([CAP].[GARPT$]) AS [SumOfGARPT$]
				FROM GA AS CAP
				WHERE (LEFT([CAP].[GAMTRX], 1) <> '9') AND [CAP].[SubprojectNumber] = 1 AND GAACTP = @curMonth
				GROUP BY [CAP].[ProjectNumber], [CAP].[SubprojectNumber], [CAP].[GAACTY], [CAP].[GAACTP]
				UNION (
					SELECT [COR].[ProjectNumber], [COR].[SubprojectNumber], [COR].[GAACTY], [COR].[GAACTP], Sum([COR].[GARPT$]) AS [SumOfGARPT$]
					FROM GA AS COR
					WHERE (LEFT([COR].[GAMTRX], 1) <> '9') AND [COR].[SubprojectNumber] = 4 AND GAACTP = @curMonth
					GROUP BY [COR].[ProjectNumber], [COR].[SubprojectNumber], [COR].[GAACTY], [COR].[GAACTP]
				)
			) AS R

			-- Update existing or insert new monthly total direct gross adds
			MERGE forecast.GrossAddsDirect G
			USING @t T
			ON G.ProjectNumber = T.ProjectNumber AND G.SubprojectNumber = T.SubprojectNumber AND G.[Year] = IIF(@year IS NOT NULL, @year, YEAR(GETDATE()))
			WHEN MATCHED THEN
				UPDATE
				SET G.[January] = IIF(T.[GAACTP] = 1, T.[SumOfGARPT$], G.[January]),
					G.[February] = IIF(T.[GAACTP] = 2, T.[SumOfGARPT$], G.[February]),
					G.[March] = IIF(T.[GAACTP] = 3, T.[SumOfGARPT$], G.[March]),
					G.[April] = IIF(T.[GAACTP] = 4, T.[SumOfGARPT$], G.[April]),
					G.[May] = IIF(T.[GAACTP] = 5, T.[SumOfGARPT$], G.[May]),
					G.[June] = IIF(T.[GAACTP] = 6, T.[SumOfGARPT$], G.[June]),
					G.[July] = IIF(T.[GAACTP] = 7, T.[SumOfGARPT$], G.[July]),
					G.[August] = IIF(T.[GAACTP] = 8, T.[SumOfGARPT$], G.[August]),
					G.[September] = IIF(T.[GAACTP] = 9, T.[SumOfGARPT$], G.[September]),
					G.[October] = IIF(T.[GAACTP] = 10, T.[SumOfGARPT$], G.[October]),
					G.[November] = IIF(T.[GAACTP] = 11, T.[SumOfGARPT$], G.[November]),
					G.[December] = IIF(T.[GAACTP] = 12, T.[SumOfGARPT$], G.[December])
			WHEN NOT MATCHED THEN
				INSERT (ProjectNumber, SubprojectNumber, [Year], January, February, March, April, May, June, July, August, September, October, November, December)
				VALUES (T.ProjectNumber, T.SubprojectNumber, IIF(@year IS NOT NULL, @year, YEAR(GETDATE())), 
							IIF(T.[GAACTP] = 1, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 2, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 3, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 4, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 5, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 6, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 7, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 8, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 9, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 10, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 11, T.[SumOfGARPT$], 0),
							IIF(T.[GAACTP] = 12, T.[SumOfGARPT$], 0));

			-- Find sum of indirect gross adds
			INSERT INTO  @u ([ProjectNumber], [SubprojectNumber], [GAACTY], [GAACTP], [SumOfGARPT$])
			SELECT R.[ProjectNumber], R.[SubprojectNumber], R.[GAACTY], R.[GAACTP], R.[SumOfGARPT$]
			FROM (
				SELECT [CAP].[ProjectNumber], [CAP].[SubprojectNumber], [CAP].[GAACTY], [CAP].[GAACTP], Sum([CAP].[GARPT$]) AS [SumOfGARPT$]
				FROM GA AS CAP
				WHERE (LEFT([CAP].[GAMTRX], 1) = '9') AND [CAP].[SubprojectNumber] = 1 AND GAACTP = @curMonth
				GROUP BY [CAP].[ProjectNumber], [CAP].[SubprojectNumber], [CAP].[GAACTY], [CAP].[GAACTP]
				UNION (
					SELECT [COR].[ProjectNumber], [COR].[SubprojectNumber], [COR].[GAACTY], [COR].[GAACTP], Sum([COR].[GARPT$]) AS [SumOfGARPT$]
					FROM GA AS COR
					WHERE (LEFT([COR].[GAMTRX], 1) = '9') AND [COR].[SubprojectNumber] = 4 AND GAACTP = @curMonth
					GROUP BY [COR].[ProjectNumber], [COR].[SubprojectNumber], [COR].[GAACTY], [COR].[GAACTP]
				)
			) AS R

			-- Update existing or insert new monthly total indirect gross adds
			MERGE forecast.GrossAddsIndirect G
			USING @u U
			ON G.ProjectNumber = U.ProjectNumber AND G.SubprojectNumber = U.SubprojectNumber AND G.[Year] = IIF(@year IS NOT NULL, @year, YEAR(GETDATE()))
			WHEN MATCHED THEN
				UPDATE
				SET G.[January] = IIF(U.[GAACTP] = 1, U.[SumOfGARPT$], G.[January]),
					G.[February] = IIF(U.[GAACTP] = 2, U.[SumOfGARPT$], G.[February]),
					G.[March] = IIF(U.[GAACTP] = 3, U.[SumOfGARPT$], G.[March]),
					G.[April] = IIF(U.[GAACTP] = 4, U.[SumOfGARPT$], G.[April]),
					G.[May] = IIF(U.[GAACTP] = 5, U.[SumOfGARPT$], G.[May]),
					G.[June] = IIF(U.[GAACTP] = 6, U.[SumOfGARPT$], G.[June]),
					G.[July] = IIF(U.[GAACTP] = 7, U.[SumOfGARPT$], G.[July]),
					G.[August] = IIF(U.[GAACTP] = 8, U.[SumOfGARPT$], G.[August]),
					G.[September] = IIF(U.[GAACTP] = 9, U.[SumOfGARPT$], G.[September]),
					G.[October] = IIF(U.[GAACTP] = 10, U.[SumOfGARPT$], G.[October]),
					G.[November] = IIF(U.[GAACTP] = 11, U.[SumOfGARPT$], G.[November]),
					G.[December] = IIF(U.[GAACTP] = 12, U.[SumOfGARPT$], G.[December])
			WHEN NOT MATCHED THEN
				INSERT (ProjectNumber, SubprojectNumber, [Year], January, February, March, April, May, June, July, August, September, October, November, December)
				VALUES (U.ProjectNumber, U.SubprojectNumber, IIF(@year IS NOT NULL, @year, YEAR(GETDATE())), 
							IIF(U.[GAACTP] = 1, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 2, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 3, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 4, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 5, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 6, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 7, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 8, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 9, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 10, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 11, U.[SumOfGARPT$], 0),
							IIF(U.[GAACTP] = 12, U.[SumOfGARPT$], 0));

			SET @curMonth = @curMonth + 1
		END
	
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateGrossAdds P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateGrossAdds
	
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH