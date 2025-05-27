CREATE PROCEDURE [log].[ct_rows_columns]
AS
BEGIN
    SET NOCOUNT ON;

    -- Create the table if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'ColumnRowCounts' AND schema_id = SCHEMA_ID('log') AND type = 'U')
    BEGIN
        CREATE TABLE log.ColumnRowCounts (
            PK BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            SchemaName SYSNAME NOT NULL,
            ObjectName SYSNAME NOT NULL,
            ObjectType VARCHAR(20) NOT NULL,
            ColumnCount INT NOT NULL,
            [RowCount] BIGINT NULL,
            LogDateTime DATETIME NOT NULL
        );
    END
    ELSE
    BEGIN
        -- Add LogDateTime column if it does not exist
        IF NOT EXISTS (SELECT * FROM sys.columns WHERE name = 'LogDateTime' AND object_id = OBJECT_ID('log.ColumnRowCounts'))
        BEGIN
            ALTER TABLE log.ColumnRowCounts ADD LogDateTime DATETIME NOT NULL DEFAULT GETDATE();
        END
    END

    -- Insert data into the table
    INSERT INTO log.ColumnRowCounts (
        SchemaName,
        ObjectName,
        ObjectType,
        ColumnCount,
        [RowCount],
        LogDateTime
    )
    SELECT
        OBJECT_SCHEMA_NAME(obj.object_id) AS SchemaName,
        obj.name AS ObjectName,
        obj.type_desc AS ObjectType,
        c.Columns AS ColumnCount,
        ISNULL(p.RowCnt, 0) AS [RowCount],
        GETDATE() AS LogDateTime
    FROM
        sys.objects obj
        CROSS APPLY (
            SELECT COUNT(*) AS Columns
            FROM sys.columns
            WHERE object_id = obj.object_id
        ) c
        CROSS APPLY (
            SELECT SUM(p.rows) AS RowCnt
            FROM sys.partitions p
            WHERE p.object_id = obj.object_id
            AND p.index_id < 2
        ) p
    WHERE
        obj.type IN ('U', 'V');
END