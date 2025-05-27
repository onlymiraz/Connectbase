CREATE PROCEDURE [PushPull].[Parser_JIMProjectImpactSection]
AS
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION

    DROP TABLE IF EXISTS #Temp_LZ_JIMProjectImpactSection;
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[PushPull].[LZ_JIMProjectImpactSection]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Parse JIMProjectImpactSection')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_LZ_JIMProjectImpactSection
	FROM [LOG].[Tracker]

	TRUNCATE TABLE [PushPull].[LZ_JIMProjectImpactSection];


	INSERT INTO [PushPull].[LZ_JIMProjectImpactSection] ([ProjectNumber])
	SELECT [Infinium_ProjectNumber]
	FROM [LZ].[infinium_project_budget];

	UPDATE p 
	SET p.[OriginalProjectBudgetDirect] = a.[OrigBudgDirect]
	from [PushPull].[OriginalBudget] a
	JOIN [PushPull].[LZ_JIMProjectImpactSection] p 
	ON a.ProjectMasterNumbr = p.ProjectNumber

	UPDATE p 
	SET p.[ProjectSpendToDate] = a.[GARPT$]
	from [history].[GALisa] a
	JOIN [PushPull].[LZ_JIMProjectImpactSection] p 
	ON a.GAPRJ# = p.ProjectNumber

  	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_LZ_JIMProjectImpactSection P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_LZ_JIMProjectImpactSection  

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@trancount > 0 ROLLBACK TRANSACTION
    EXEC usp_error_handler
    RETURN 55555
END CATCH;