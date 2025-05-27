-- Specify the service accounts for CORP\s_WAD0 through CORP\s_WAD4
DECLARE @serviceAccounts TABLE (ServiceAccount NVARCHAR(255));

INSERT INTO @serviceAccounts (ServiceAccount)
VALUES ('CORP\WAD_Developers');

-- Specify databases for readonly and readwrite access
DECLARE @readonlyDatabases TABLE (DatabaseName NVARCHAR(255));
DECLARE @readwriteDatabases TABLE (DatabaseName NVARCHAR(255));

INSERT INTO @readonlyDatabases (DatabaseName)
VALUES ('WAD_STG_01'), ('WAD_STG_02');

INSERT INTO @readwriteDatabases (DatabaseName)
VALUES ('WAD_STG_Scratchpad'), ('WAD_PRD_Scratchpad'), ('Playground');

-- Loop through each service account
DECLARE @serviceAccount NVARCHAR(255);

DECLARE service_cursor CURSOR FOR
SELECT ServiceAccount FROM @serviceAccounts;

OPEN service_cursor;

FETCH NEXT FROM service_cursor INTO @serviceAccount;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Check if the server principal exists
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @serviceAccount)
    BEGIN
        -- If not, create the server principal
        DECLARE @sqlCreateServerPrincipal NVARCHAR(MAX);
        SET @sqlCreateServerPrincipal = 'CREATE LOGIN [' + @serviceAccount + '] FROM WINDOWS;';
        EXEC sp_executesql @sqlCreateServerPrincipal;
    END

    -- Loop through all user databases
    DECLARE @databaseName NVARCHAR(255);

    DECLARE db_cursor CURSOR FOR
    SELECT name FROM sys.databases WHERE database_id > 4 AND state_desc = 'ONLINE';

    OPEN db_cursor;

    FETCH NEXT FROM db_cursor INTO @databaseName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the login already exists in the current database with a different user name
        IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE sid = SUSER_SID(@serviceAccount) AND name <> @serviceAccount)
        BEGIN
            -- Determine the access level based on the database
            DECLARE @sqlAccess NVARCHAR(MAX);

            IF EXISTS (SELECT 1 FROM @readonlyDatabases WHERE DatabaseName = @databaseName)
                SET @sqlAccess = 'READ_ONLY';
            ELSE IF EXISTS (SELECT 1 FROM @readwriteDatabases WHERE DatabaseName = @databaseName)
                SET @sqlAccess = 'READ_WRITE';
            ELSE
                SET @sqlAccess = 'NO_ACCESS';

            -- Apply the access level
            IF @sqlAccess = 'READ_ONLY'
            BEGIN
                DECLARE @sqlDbReadonly NVARCHAR(MAX);
                SET @sqlDbReadonly = 
                    'USE [' + @databaseName + '];
                    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ''' + @serviceAccount + ''')
                    BEGIN
                        CREATE USER [' + @serviceAccount + '] FOR LOGIN [' + @serviceAccount + '];
                        ALTER ROLE db_datareader ADD MEMBER [' + @serviceAccount + '];
                    END';
                EXEC sp_executesql @sqlDbReadonly;
            END
            ELSE IF @sqlAccess = 'READ_WRITE'
            BEGIN
                DECLARE @sqlDbReadwrite NVARCHAR(MAX);
                SET @sqlDbReadwrite = 
                    'USE [' + @databaseName + '];
                    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ''' + @serviceAccount + ''')
                    BEGIN
                        CREATE USER [' + @serviceAccount + '] FOR LOGIN [' + @serviceAccount + '];
                        ALTER ROLE db_datawriter ADD MEMBER [' + @serviceAccount + '];
                    END';
                EXEC sp_executesql @sqlDbReadwrite;
            END
        END

        FETCH NEXT FROM db_cursor INTO @databaseName;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;

    FETCH NEXT FROM service_cursor INTO @serviceAccount;
END

CLOSE service_cursor;
DEALLOCATE service_cursor;
