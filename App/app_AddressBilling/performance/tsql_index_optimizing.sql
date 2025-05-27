USE [Playground];
GO

-------------------------------------------------------------------------------
-- STEP 1: Check each column for any data longer than our chosen limit
--         If found, we print an error and stop. Adjust lengths as needed.
-------------------------------------------------------------------------------
IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([batch_id]) > 36
)
BEGIN
    PRINT 'ERROR: Some batch_id values exceed 36 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([user_def_row_ID]) > 100
)
BEGIN
    PRINT 'ERROR: Some user_def_row_ID values exceed 100 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([Input_Address]) > 200
)
BEGIN
    PRINT 'ERROR: Some Input_Address values exceed 200 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([Matched_Address]) > 200
)
BEGIN
    PRINT 'ERROR: Some Matched_Address values exceed 200 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([Input_City]) > 100
)
BEGIN
    PRINT 'ERROR: Some Input_City values exceed 100 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([Matched_City]) > 100
)
BEGIN
    PRINT 'ERROR: Some Matched_City values exceed 100 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([Input_State]) > 50
)
BEGIN
    PRINT 'ERROR: Some Input_State values exceed 50 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([Matched_State]) > 50
)
BEGIN
    PRINT 'ERROR: Some Matched_State values exceed 50 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([Input_Zip]) > 20
)
BEGIN
    PRINT 'ERROR: Some Input_Zip values exceed 20 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([Matched_Zip]) > 20
)
BEGIN
    PRINT 'ERROR: Some Matched_Zip values exceed 20 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([BLL_UniqueID]) > 50
)
BEGIN
    PRINT 'ERROR: Some BLL_UniqueID values exceed 50 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([PRICING_TIER]) > 50
)
BEGIN
    PRINT 'ERROR: Some PRICING_TIER values exceed 50 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([LIT]) > 50
)
BEGIN
    PRINT 'ERROR: Some LIT values exceed 50 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([EthernetLit]) > 50
)
BEGIN
    PRINT 'ERROR: Some EthernetLit values exceed 50 characters. Handle them, then rerun.';
    RETURN;
END;

IF EXISTS (
    SELECT 1
    FROM [addressbilling].[Fuzzymatch_Output]
    WHERE LEN([SWC]) > 50
)
BEGIN
    PRINT 'ERROR: Some SWC values exceed 50 characters. Handle them, then rerun.';
    RETURN;
END;

-------------------------------------------------------------------------------
-- STEP 2: ALTER each column from VARCHAR(MAX) to a fixed length.
--         Adjust the lengths to suit your actual data requirements.
-------------------------------------------------------------------------------
ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [batch_id]       VARCHAR(36) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [user_def_row_ID] VARCHAR(100) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [Input_Address]   VARCHAR(200) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [Matched_Address] VARCHAR(200) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [Input_City]      VARCHAR(100) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [Matched_City]    VARCHAR(100) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [Input_State]     VARCHAR(50) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [Matched_State]   VARCHAR(50) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [Input_Zip]       VARCHAR(20) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [Matched_Zip]     VARCHAR(20) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [BLL_UniqueID]    VARCHAR(50) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [PRICING_TIER]    VARCHAR(50) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [LIT]             VARCHAR(50) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [EthernetLit]     VARCHAR(50) NULL;

ALTER TABLE [addressbilling].[Fuzzymatch_Output]
    ALTER COLUMN [SWC]             VARCHAR(50) NULL;
GO

-------------------------------------------------------------------------------
-- STEP 3: Create a nonclustered index on (batch_id, ID).
--         Now that batch_id is no longer VARCHAR(MAX), indexing is allowed.
-------------------------------------------------------------------------------
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[addressbilling].[Fuzzymatch_Output]')
      AND name = N'IX_Fuzzymatch_Output_batchid_id'
)
BEGIN
    DROP INDEX [IX_Fuzzymatch_Output_batchid_id]
        ON [addressbilling].[Fuzzymatch_Output];
END;
GO

CREATE NONCLUSTERED INDEX [IX_Fuzzymatch_Output_batchid_id]
ON [addressbilling].[Fuzzymatch_Output]([batch_id],[ID])
-- Optionally INCLUDE commonly selected columns, e.g.:
-- INCLUDE ([Matched_Address],[Matched_City],[Matched_State],[Matched_Zip],[ingestion_timestamp])
WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, ONLINE = ON);
GO
