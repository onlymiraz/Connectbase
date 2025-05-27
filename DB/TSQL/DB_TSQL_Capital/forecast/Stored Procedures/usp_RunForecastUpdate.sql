CREATE PROCEDURE [forecast].[usp_RunForecastUpdate]
	-- Add the parameters for the stored procedure here
	@ga_start_month int,
	@ga_end_month int
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_RunForecastUpdate
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_RunForecastUpdate]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_RunForecastUpdate
FROM [LOG].[Tracker]

		-- Clean Tables
		--EXEC forecast.usp_CleanTables

		----Correct Prior Year (Once a year at the beginning - Year to Year transition)
		--EXEC [forecast].[usp_PriorYearNew]

		-- Bulk insert queries and import from dbo.ForecastImport table
		--EXEC forecast.usp_BulkInsertQueries
		--EXEC [forecast].[usp_ManualAnalystUpdates]
		EXEC history.usp_GA
		--EXEC [forecast].[usp_GA_reset]
		--Correct Python GA
		EXEC [forecast].[usp_GA_BenefitsLoad]
		EXEC [forecast].[usp_GA_PythonCorrection]
		

		EXEC forecast.usp_FixImports
		--EXEC forecast.usp_RunForecastFileImport

		-- Update forecast tables from query tables
		--EXEC forecast.usp_ImportProjectsFromTable
		EXEC forecast.usp_UpdateApproved
		EXEC forecast.usp_UpdateBudgetLineProjects
		
		--Gross Adds
		DECLARE @curYr int = CAST(YEAR(GETDATE()) AS INT)
		DECLARE @curMo int = CAST(MONTH(GETDATE()) AS INT)
		DECLARE @curDay int = CAST(DAY(GETDATE()) AS INT)
		DECLARE @i int = 1
/*		
		--Normal
		WHILE @curMo>1 and @curMo<12 and @i=1
			BEGIN
				EXEC forecast.usp_UpdateGrossAdds @year = @curYr, @start_month = @ga_start_month, @end_month = @ga_end_month
				SET @i+=1
			END
		
		--Jan
		SET @i=1
		WHILE @curMo=1 AND @curDay>7 and @i<3
			BEGIN
				EXEC forecast.usp_UpdateGrossAdds @year = @curYr, @start_month = @ga_start_month, @end_month = @ga_end_month
				SET @curYr-=1
				SET @i+=1
			END

		--Dec
		SET @i=1
		WHILE (@curMo=12 AND @curDay>22) or (@curMo=1 AND @curDay<8)
			BEGIN
				EXEC forecast.usp_UpdateGrossAdds @year = @curYr, @start_month = @ga_start_month, @end_month = @ga_end_month
				SET @curYr+=1
			END
*/
		EXEC forecast.usp_UpdateGrossAdds @year = @curYr, @start_month = @ga_start_month, @end_month = @ga_end_month
		--EXEC forecast.usp_CorrectGrossAdds
		

		EXEC forecast.usp_UpdateFFFIELDS
		EXEC forecast.usp_UpdateBudgetCategory
		EXEC forecast.usp_UpdateAuthorized
		EXEC forecast.usp_UpdateCIAC
		EXEC forecast.usp_UpdatePriorYearsSpent
		EXEC forecast.usp_UpdateFutureYear
		EXEC forecast.usp_UpdateSpread
		EXEC forecast.usp_UpdateSubprojectStatus
		EXEC forecast.usp_UpdateMisc
		EXEC forecast.usp_UpdateVarassetStatus
		
		-- Create export and error report
		EXEC forecast.usp_CreateForecastExport @year = @curYr
		--EXEC history.usp_DeleteDuplicatesHistoryFF
		--EXEC forecast.usp_CreateForecastSummary
		--EXEC forecast.usp_CreateErrorReport

		--EXEC [FTTH].[Reports_All]
		--EXEC ProjApproval.usp_ComputeNPV
		--EXEC [FTTH].[usp_BulkUsageEntrySubmit]
	
	
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_RunForecastUpdate P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_RunForecastUpdate


INSERT INTO [LOG].[CapitalGA]
           ([SysDateTime]
           ,[GAStart]
           ,[GAEnd])
     VALUES
           (GETDATE()
           ,@ga_start_month
           ,@ga_end_month)

	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH