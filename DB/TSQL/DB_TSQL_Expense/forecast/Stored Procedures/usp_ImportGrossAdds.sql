-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_ImportGrossAdds]
	@year smallint
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ImportGrossAdds
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_ImportGrossAdds]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_ImportGrossAdds
FROM [LOG].[Tracker]


		-- Update or insert gross adds direct table
		MERGE forecast.GrossAddsDirect AS G
		USING dbo.ForecastImport AS F
		ON (G.ProjectNumber = F.ProjectNumber AND G.SubprojectNumber = F.SubprojectNumber AND G.[Year] = IIF(@year IS NOT NULL, @year, YEAR(GETDATE())))
		WHEN MATCHED THEN
			UPDATE
			SET G.January = ISNULL(F.JanuaryDirect, 0),
				G.February = ISNULL(F.FebruaryDirect, 0),
				G.March = ISNULL(F.MarchDirect, 0),
				G.April = ISNULL(F.AprilDirect, 0),
				G.May = ISNULL(F.MayDirect, 0),
				G.June = ISNULL(F.JuneDirect, 0),
				G.July = ISNULL(F.JulyDirect, 0),
				G.August = ISNULL(F.AugustDirect, 0),
				G.September = ISNULL(F.SeptemberDirect, 0),
				G.October = ISNULL(F.OctoberDirect, 0),
				G.November = ISNULL(F.NovemberDirect, 0),
				G.December = ISNULL(F.DecemberDirect, 0)
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, [Year], January, February, March, April, May, 
					June, July, August, September, October, November, December)
			VALUES (F.ProjectNumber, F.SubprojectNumber, IIF(@year IS NOT NULL, @year, YEAR(GETDATE())), 
					ISNULL(F.JanuaryDirect, 0), ISNULL(F.FebruaryDirect, 0), ISNULL(F.MarchDirect, 0), ISNULL(F.AprilDirect, 0), ISNULL(F.MayDirect, 0), ISNULL(F.JuneDirect, 0),
					ISNULL(F.JulyDirect, 0), ISNULL(F.AugustDirect, 0), ISNULL(F.SeptemberDirect, 0), ISNULL(F.OctoberDirect, 0), ISNULL(F.NovemberDirect, 0), ISNULL(F.DecemberDirect, 0));
					
		-- Update or insert gross adds indirect table
		MERGE forecast.GrossAddsIndirect AS G
		USING dbo.ForecastImport AS F
		ON (G.ProjectNumber = F.ProjectNumber AND G.SubprojectNumber = F.SubprojectNumber AND G.[Year] = IIF(@year IS NOT NULL, @year, YEAR(GETDATE())))
		WHEN MATCHED THEN
			UPDATE
			SET G.January = ISNULL(F.JanuaryIndirect, 0),
				G.February = ISNULL(F.FebruaryIndirect, 0),
				G.March = ISNULL(F.MarchIndirect, 0),
				G.April = ISNULL(F.AprilIndirect, 0),
				G.May = ISNULL(F.MayIndirect, 0),
				G.June = ISNULL(F.JuneIndirect, 0),
				G.July = ISNULL(F.JulyIndirect, 0),
				G.August = ISNULL(F.AugustIndirect, 0),
				G.September = ISNULL(F.SeptemberIndirect, 0),
				G.October = ISNULL(F.OctoberIndirect, 0),
				G.November = ISNULL(F.NovemberIndirect, 0),
				G.December = ISNULL(F.DecemberIndirect, 0)
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, [Year], January, February, March, April, May, 
					June, July, August, September, October, November, December)
			VALUES (F.ProjectNumber, F.SubprojectNumber, IIF(@year IS NOT NULL, @year, YEAR(GETDATE())),
					ISNULL(F.JanuaryIndirect, 0), ISNULL(F.FebruaryIndirect, 0), ISNULL(F.MarchIndirect, 0), ISNULL(F.AprilIndirect, 0), ISNULL(F.MayIndirect, 0), ISNULL(F.JuneIndirect, 0),
					ISNULL(F.JulyIndirect, 0), ISNULL(F.AugustIndirect, 0), ISNULL(F.SeptemberIndirect, 0), ISNULL(F.OctoberIndirect, 0), ISNULL(F.NovemberIndirect, 0), ISNULL(F.DecemberIndirect, 0));
	
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_ImportGrossAdds P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ImportGrossAdds

	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH