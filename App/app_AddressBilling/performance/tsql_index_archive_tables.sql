USE [Playground];
GO

-------------------------------------------------------------------------------
-- 1) [addressbilling].[UI_LZ_Archive]
--    When we query or fallback to the archive by batch_id,
--    let's add an index on (batch_id, ingestion_timestamp).
-------------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[addressbilling].[UI_LZ_Archive]')
      AND name = 'IX_UI_LZ_Archive_batchid_ingest'
)
BEGIN
    PRINT 'Creating index IX_UI_LZ_Archive_batchid_ingest...';
    CREATE NONCLUSTERED INDEX [IX_UI_LZ_Archive_batchid_ingest]
        ON [addressbilling].[UI_LZ_Archive] (
            [batch_id],
            [ingestion_timestamp]
        )
        INCLUDE (
            [user_def_row_ID],
            [user_email],
            [process_status],
            [Address1],
            [City],
            [State],
            [Zip]
        )
        WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, ONLINE = ON);
END
ELSE
BEGIN
    PRINT 'Index IX_UI_LZ_Archive_batchid_ingest already exists.';
END;
GO

-------------------------------------------------------------------------------
-- 2) [addressbilling].[Fuzzymatch_Output_Archive]
--    We often query by batch_id, ID or by ingestion_timestamp or matched state.
--    Let's do (batch_id, ID) + optionally (Matched_State).
-------------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[addressbilling].[Fuzzymatch_Output_Archive]')
      AND name = 'IX_FuzzymatchOutputArch_batchid_id'
)
BEGIN
    PRINT 'Creating index IX_FuzzymatchOutputArch_batchid_id...';
    CREATE NONCLUSTERED INDEX [IX_FuzzymatchOutputArch_batchid_id]
        ON [addressbilling].[Fuzzymatch_Output_Archive] (
            [batch_id],
            [ID]
        )
        INCLUDE (
            [ingestion_timestamp],
            [Matched_Address],
            [Matched_City],
            [Matched_State],
            [Matched_Zip]
        )
        WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, ONLINE = ON);
END
ELSE
BEGIN
    PRINT 'Index IX_FuzzymatchOutputArch_batchid_id already exists.';
END;
GO

-------------------------------------------------------------------------------
-- Optional: Also index Matched_State for quick filtering by state
-------------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[addressbilling].[Fuzzymatch_Output_Archive]')
      AND name = 'IX_FuzzymatchOutputArch_state'
)
BEGIN
    PRINT 'Creating index IX_FuzzymatchOutputArch_state...';
    CREATE NONCLUSTERED INDEX [IX_FuzzymatchOutputArch_state]
        ON [addressbilling].[Fuzzymatch_Output_Archive] (
            [Matched_State]
        )
        INCLUDE (
            [batch_id],
            [ID],
            [ingestion_timestamp],
            [Matched_Address],
            [Matched_City]
        )
        WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, ONLINE = ON);
END
ELSE
BEGIN
    PRINT 'Index IX_FuzzymatchOutputArch_state already exists.';
END;
GO

-------------------------------------------------------------------------------
-- 3) Update stats
-------------------------------------------------------------------------------
UPDATE STATISTICS [addressbilling].[UI_LZ_Archive] WITH FULLSCAN;
UPDATE STATISTICS [addressbilling].[Fuzzymatch_Output_Archive] WITH FULLSCAN;

PRINT 'Archive table indexes created or verified. Stats updated.';
GO
