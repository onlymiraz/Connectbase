USE [Playground];
GO

-------------------------------------------------------------------------------
-- 1) [addressbilling].[Fuzzymatch_Output]
--    Common usage:  WHERE batch_id=?   ORDER BY ID
--    => Index on (batch_id, ID) helps filter by batch_id and sort by ID.
-------------------------------------------------------------------------------
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[addressbilling].[Fuzzymatch_Output]')
      AND name = 'IX_Fuzzymatch_Output_batchid_id'
)
BEGIN
    DROP INDEX [IX_Fuzzymatch_Output_batchid_id]
        ON [addressbilling].[Fuzzymatch_Output];
END;
GO

CREATE NONCLUSTERED INDEX [IX_Fuzzymatch_Output_batchid_id]
    ON [addressbilling].[Fuzzymatch_Output] ([batch_id],[ID])
    -- Optionally INCLUDE columns you frequently SELECT:
    -- (Use columns actually queried after filtering by batch_id.)
    -- Example:
    -- INCLUDE (
    --     [ingestion_timestamp],
    --     [Matched_Address],
    --     [Matched_City],
    --     [Matched_State],
    --     [Matched_Zip]
    -- )
    WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, ONLINE = ON);
GO

-------------------------------------------------------------------------------
-- 2) [addressbilling].[UI_LZ]
--    PK already on (ID). 
--    From the code, we see queries like:
--       a) WHERE batch_id=? AND user_name=?
--       b) WHERE process_status='pending' GROUP BY batch_id
--       c) Possibly sorting or grouping by ingestion_timestamp
--
--    => We'll add:
--       i) Index on (process_status, batch_id) 
--       ii) Index on (batch_id, user_name)
--       iii) (Optional) Index on ingestion_timestamp if needed
-------------------------------------------------------------------------------

-- 2a) index (process_status, batch_id)
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[addressbilling].[UI_LZ]')
      AND name = 'IX_UI_LZ_status_batch'
)
BEGIN
    DROP INDEX [IX_UI_LZ_status_batch]
        ON [addressbilling].[UI_LZ];
END;
GO

CREATE NONCLUSTERED INDEX [IX_UI_LZ_status_batch]
    ON [addressbilling].[UI_LZ] ([process_status], [batch_id])
    -- INCLUDE columns commonly selected with these filters:
    INCLUDE (
        [ingestion_timestamp],
        [user_email],
        [user_name]
        -- add or remove columns as needed
    )
    WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, ONLINE = ON);
GO

-- 2b) index (batch_id, user_name)
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[addressbilling].[UI_LZ]')
      AND name = 'IX_UI_LZ_batchid_username'
)
BEGIN
    DROP INDEX [IX_UI_LZ_batchid_username]
        ON [addressbilling].[UI_LZ];
END;
GO

CREATE NONCLUSTERED INDEX [IX_UI_LZ_batchid_username]
    ON [addressbilling].[UI_LZ] ([batch_id], [user_name])
    -- INCLUDE columns commonly read in the result
    INCLUDE (
        [ingestion_timestamp],
        [user_email],
        [process_status]
        -- add or remove columns as needed
    )
    WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, ONLINE = ON);
GO

-- 2c) optional: if you frequently filter or sort by ingestion_timestamp
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'[addressbilling].[UI_LZ]')
      AND name = 'IX_UI_LZ_ingestion_timestamp'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UI_LZ_ingestion_timestamp]
        ON [addressbilling].[UI_LZ] ([ingestion_timestamp])
        -- INCLUDE columns you also retrieve in date-based queries:
        INCLUDE (
            [batch_id],
            [user_name],
            [process_status],
            [user_email]
        )
        WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, ONLINE = ON);
END;
GO


-------------------------------------------------------------------------------
-- 3) (Optional) Update statistics to give the optimizer fresh info.
-------------------------------------------------------------------------------
UPDATE STATISTICS [addressbilling].[Fuzzymatch_Output] WITH FULLSCAN;
UPDATE STATISTICS [addressbilling].[UI_LZ] WITH FULLSCAN;
GO

-------------------------------------------------------------------------------
-- Done. You now have recommended indexes for typical usage patterns.
-------------------------------------------------------------------------------
PRINT 'Indexes successfully created! Stats updated.'; 
