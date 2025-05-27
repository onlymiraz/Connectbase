CREATE PROCEDURE [PushPull].[parser_ProjectSummarySection]
AS
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION

    DROP TABLE IF EXISTS #Temp_LZ_ProjectSummarySection;

    INSERT INTO [LOG].[Tracker]
        ([EVENTNAME]
        ,[EVENTSTART]
        ,[EVENTTYPE]
        ,[EVENTDESCRIPTION])
    VALUES
        ('[PushPull].[LZ_ProjectSummarySection]'
        ,CAST(GETDATE() AS DATETIME)
        ,'STORE PROC'
        ,'Ingest LZ_ProjectSummarySection.csv');

    SELECT MAX(EVENTID) AS LATESTID INTO #Temp_LZ_ProjectSummarySection
    FROM [LOG].[Tracker];

    SET NOCOUNT ON;

    TRUNCATE TABLE [PushPull].[LZ_ProjectSummarySection];

    BULK INSERT [PushPull].[LZ_ProjectSummarySection]
    FROM 'd:\DataDump\LZ_ProjectSummarySection.csv'

    WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE=65001, FIRSTROW=2);


    UPDATE [PushPull].[LZ_ProjectSummarySection]
    SET ProjectID = REPLACE(ProjectID, '"', ''),
        ClassofPlant = REPLACE(ClassofPlant, '"', ''),
        EstimatedInServiceDate = REPLACE(EstimatedInServiceDate, '"', ''),
        JustificationCode = REPLACE(JustificationCode, '"', ''),
        ProjectStatus = REPLACE(ProjectStatus, '"', ''),
        ApprovalCode = REPLACE(ApprovalCode, '"', ''),
        [Feeder/Distribution] = REPLACE([Feeder/Distribution], '"', ''),
        VarassetStatus = REPLACE(VarassetStatus, '"', ''),
        OverageDriver = REPLACE(OverageDriver, '"', ''),
        ConstructionVendor = REPLACE(ConstructionVendor, '"', ''),
        Wirecenter = REPLACE(Wirecenter, '"', ''),
        [State] = REPLACE([State], '"', ''),
        Region = REPLACE(Region, '"', '');

    UPDATE B
    SET B.EVENTEND = CAST(GETDATE() AS DATETIME)
    FROM LOG.Tracker B
    INNER JOIN #Temp_LZ_ProjectSummarySection P
    ON B.EVENTID = P.LATESTID;


     

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@trancount > 0 ROLLBACK TRANSACTION
    EXEC usp_error_handler
    RETURN 55555
END CATCH;