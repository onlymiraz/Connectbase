CREATE PROCEDURE LZ.[usp_SFTP_CB_DE]
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

                -- --LOGGER: Insert log entry and get the latest EVENTID
        DECLARE @LatestEventID INT;
        INSERT INTO [LOG].tbl_storeproc
            ([EVENTNAME], [EVENTSTART], [EVENTTYPE], [EVENTDESCRIPTION])
        VALUES
            ('LZ.[usp_SFTP_CB_DE]', GETDATE(), 'STORE PROC', 'daily parser');

        SELECT @LatestEventID = SCOPE_IDENTITY();

        -- Declare variables for table names and file paths
        DECLARE @TableName NVARCHAR(255);
        DECLARE @FilePath NVARCHAR(255);

        -- Temporary table for storing table names and file paths
        CREATE TABLE #FileTable (
            TableName NVARCHAR(255),
            FilePath NVARCHAR(255)
        );

        -- Insert table names and file paths
        INSERT INTO #FileTable (TableName, FilePath)
        VALUES 
            ('LZ.[SFTP_CB_DE_750]', 'D:\LZ\IT_Data_Transmission\CB_FRONTIER_DEMAND_ENGINE_ACTIVITIES_750.csv'),
            ('LZ.[SFTP_CB_DE_819]', 'D:\LZ\IT_Data_Transmission\CB_FRONTIER_DEMAND_ENGINE_ACTIVITIES_819.csv');

        -- Loop through the temporary table
        WHILE EXISTS (SELECT * FROM #FileTable)
        BEGIN
            -- Get the top record
            SELECT TOP 1 @TableName = TableName, @FilePath = FilePath
            FROM #FileTable;

            -- Truncate the table
            DECLARE @SQL NVARCHAR(MAX) = 'TRUNCATE TABLE ' + @TableName;
            EXEC sp_executesql @SQL;

            -- Bulk insert data
            SET @SQL = 'BULK INSERT ' + @TableName + '
                        FROM ''' + @FilePath + '''
                        WITH
                        (
                            FIELDTERMINATOR = ''|'',  
                            ROWTERMINATOR = ''\n'',
                            FIRSTROW = 2,
                            BATCHSIZE = 15000
                        )';
            EXEC sp_executesql @SQL;

            -- Update the COUNTRY column
            SET @SQL = 'UPDATE ' + @TableName + '
                        SET COUNTRY = REPLACE(REPLACE(REPLACE(COUNTRY, '' | '', ''''), ''|'', ''''), ''"'', '''')';
            EXEC sp_executesql @SQL;

            -- Clean the ERRORMESSAGE column by removing empty single or double quotes
            SET @SQL = 'UPDATE ' + @TableName + '
                        SET ERROR_MESSAGE = REPLACE(REPLACE(ERROR_MESSAGE, ''"'', ''''), '''', '''')';
            EXEC sp_executesql @SQL;

            -- Delete the processed record from the temporary table
            DELETE FROM #FileTable
            WHERE TableName = @TableName AND FilePath = @FilePath;
        END

        -- Drop the temporary table
        DROP TABLE #FileTable;

        --LOGGER: Update the log entry
        UPDATE LOG.tbl_storeproc
        SET EVENTEND = GETDATE()
        WHERE EVENTID = @LatestEventID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC usp_error_handler;
        RETURN 55555;
    END CATCH
END;