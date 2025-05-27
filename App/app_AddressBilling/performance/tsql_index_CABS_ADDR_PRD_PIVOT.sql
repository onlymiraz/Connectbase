USE [WAD_PRD_Integration];
GO

ALTER TABLE [ADDRESS_BILLING].[CABS_ADDR_PRD_PIVOT]
    ADD [AddressTrunc] AS LEFT([ADDRESS], 200) PERSISTED;

-- Then index that new column
CREATE NONCLUSTERED INDEX [IX_CABS_PIVOT_AddressTrunc_CityState]
    ON [ADDRESS_BILLING].[CABS_ADDR_PRD_PIVOT] ([AddressTrunc], [CITY], [STATE])
    INCLUDE ([ZIP], [WIRELINE_ETH], [WIRELESS_ETH]);
GO


USE [WAD_PRD_Integration];
GO

-------------------------------------------------------------------------------
-- 1) Ensure that none of the values exceed the chosen lengths (e.g. 200 chars)
-------------------------------------------------------------------------------
-- For [CABS_ADDR_PRD_PIVOT]
IF EXISTS (
    SELECT 1
    FROM [ADDRESS_BILLING].[CABS_ADDR_PRD_PIVOT]
    WHERE LEN([ADDRESS]) > 200
       OR LEN([CITY]) > 100
       OR LEN([STATE]) > 50
)
BEGIN
    PRINT 'ERROR: Some rows exceed the planned lengths; fix/truncate them before running ALTER.';
    RETURN;
END

-------------------------------------------------------------------------------
-- 2) Alter columns to fixed VARCHAR(n) so they can be indexed
-------------------------------------------------------------------------------
ALTER TABLE [ADDRESS_BILLING].[CABS_ADDR_PRD_PIVOT]
    ALTER COLUMN [ADDRESS] VARCHAR(200) NULL;  -- or NOT NULL if required

ALTER TABLE [ADDRESS_BILLING].[CABS_ADDR_PRD_PIVOT]
    ALTER COLUMN [CITY] VARCHAR(100) NULL;

ALTER TABLE [ADDRESS_BILLING].[CABS_ADDR_PRD_PIVOT]
    ALTER COLUMN [STATE] VARCHAR(50)  NULL;

-- If you also want to index ZIP, consider altering it to VARCHAR(20) or so:
-- ALTER TABLE [ADDRESS_BILLING].[CABS_ADDR_PRD_PIVOT]
--     ALTER COLUMN [ZIP] VARCHAR(20) NULL;
GO


-- 3) Now that columns are non-LOB, you can create the index
CREATE NONCLUSTERED INDEX [IX_CABS_PIVOT_AddressCityState]
    ON [ADDRESS_BILLING].[CABS_ADDR_PRD_PIVOT] ([ADDRESS], [CITY], [STATE])
    INCLUDE ([ZIP], [WIRELINE_ETH], [WIRELESS_ETH])
    WITH (
        FILLFACTOR = 90,
        SORT_IN_TEMPDB = ON,
        ONLINE = ON
    );
GO
