CREATE PROCEDURE [PushPull].[parser_RegionCorporateSummarySection]
AS
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION

    DROP TABLE IF EXISTS #Temp_LZ_RegionCorporateSummarySection;
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[PushPull].[LZ_RegionCorporateSummarySection]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Parse RegionCorporateSummarySection')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_LZ_RegionCorporateSummarySection
	FROM [LOG].[Tracker]

 TRUNCATE TABLE [PushPull].[LZ_RegionCorporateSummarySection];

 INSERT INTO [PushPull].[LZ_RegionCorporateSummarySection] ([ProjectNumber])
SELECT [Infinium_ProjectNumber]
FROM [LZ].[infinium_project_budget];
  UPDATE p 
 
  SET p.[State] = a.[project_State]
 
  from [LZ].[infinium_project_budget] a
 
  JOIN [PushPull].[LZ_RegionCorporateSummarySection] p 
 
  ON a.Infinium_ProjectNumber = p.ProjectNumber

  	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_LZ_RegionCorporateSummarySection P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_LZ_RegionCorporateSummarySection 

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@trancount > 0 ROLLBACK TRANSACTION
    EXEC usp_error_handler
    RETURN 55555
END CATCH;