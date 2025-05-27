USE [Playground];
GO

DECLARE @cutoff DATETIME = DATEADD(DAY, -7, GETDATE());

/* Step A: Insert older rows INTO the archive table */
INSERT INTO [addressbilling].[Fuzzymatch_Output_Archive]
SELECT *
FROM [addressbilling].[Fuzzymatch_Output]
WHERE ingestion_timestamp < @cutoff;

/* Step B: Delete them from the main table */
DELETE F
FROM [addressbilling].[Fuzzymatch_Output] AS F
WHERE F.ingestion_timestamp < @cutoff;

PRINT 'Archive step complete!';
