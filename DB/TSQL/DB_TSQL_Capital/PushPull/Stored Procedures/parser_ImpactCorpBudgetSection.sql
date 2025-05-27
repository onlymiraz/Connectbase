CREATE PROCEDURE [pushpull].[parser_ImpactCorpBudgetSection]
AS
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION

    DROP TABLE IF EXISTS #Temp_LZ_ImpactCorpBudgetSection;
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[PushPull].[LZ_ImpactCorpBudgetSection]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'parse LZ_ImpactCorpBudgetSection')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_LZ_ImpactCorpBudgetSection
	FROM [LOG].[Tracker]

  TRUNCATE TABLE [PushPull].[LZ_ImpactCorpBudgetSection];

INSERT INTO [PushPull].[LZ_ImpactCorpBudgetSection] (State)
SELECT [project_State]
FROM [LZ].[infinium_project_budget];

  	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_LZ_ImpactCorpBudgetSection P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_LZ_ImpactCorpBudgetSection  

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@trancount > 0 ROLLBACK TRANSACTION
    EXEC usp_error_handler
    RETURN 55555
END CATCH;