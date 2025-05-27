-- Specify the service accounts for CORP\s_WAD0 through CORP\s_WAD4
DECLARE @serviceAccounts TABLE (ServiceAccount NVARCHAR(255));

INSERT INTO @serviceAccounts (ServiceAccount)
VALUES 
    ('CORP\s_WAD'),
    ('CORP\s_WAD0'),
    ('CORP\s_WAD1'),
    ('CORP\s_WAD2'),
    ('CORP\s_WAD3'),
    ('CORP\s_WAD4'),
    ('CORP\s_prod_tfssvc'),
    ('CORP\WAD_DevOps');

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

    -- Check if the server principal is already a sysadmin
    IF NOT EXISTS (SELECT 1 FROM sys.server_role_members WHERE member_principal_id = 
                   (SELECT principal_id FROM sys.server_principals WHERE name = @serviceAccount)
                   AND role_principal_id = (SELECT role_principal_id FROM sys.server_principals WHERE name = 'sysadmin'))
    BEGIN
        -- If not, make the server principal a sysadmin
        DECLARE @sqlSysadmin NVARCHAR(MAX);
        SET @sqlSysadmin = 'USE master; ALTER SERVER ROLE sysadmin ADD MEMBER [' + @serviceAccount + '];';
        EXEC sp_executesql @sqlSysadmin;
    END

    -- Loop through all user databases
    DECLARE @databaseName NVARCHAR(255);

    DECLARE db_cursor CURSOR FOR
    SELECT name FROM sys.databases WHERE database_id > -1 AND state_desc = 'ONLINE';

    OPEN db_cursor;

    FETCH NEXT FROM db_cursor INTO @databaseName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the login already exists in the current database with a different user name
        IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE sid = SUSER_SID(@serviceAccount) AND name <> @serviceAccount)
        BEGIN
            -- Make service account db_owner and create user
            DECLARE @sqlDbOwner NVARCHAR(MAX);
            SET @sqlDbOwner = 
                'USE [' + @databaseName + '];
                IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ''' + @serviceAccount + ''')
                BEGIN
                    CREATE USER [' + @serviceAccount + '] FOR LOGIN [' + @serviceAccount + '];
                    ALTER ROLE db_owner ADD MEMBER [' + @serviceAccount + '];
                END';

            EXEC sp_executesql @sqlDbOwner;
        END

        FETCH NEXT FROM db_cursor INTO @databaseName;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;

    FETCH NEXT FROM service_cursor INTO @serviceAccount;
END

CLOSE service_cursor;
DEALLOCATE service_cursor;
