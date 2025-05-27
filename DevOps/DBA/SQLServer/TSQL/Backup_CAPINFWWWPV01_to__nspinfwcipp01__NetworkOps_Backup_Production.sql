DECLARE @name NVARCHAR(256) -- database name  
DECLARE @path NVARCHAR(512) -- path for backup files  
DECLARE @fileName NVARCHAR(512) -- filename for backup  
DECLARE @fileDate NVARCHAR(40) -- used for file name

-- specify database backup directory
SET @path = '\\nspinfwcipp01\NetworkOps_Backup_Production\145\'

-- specify filename format
SELECT @fileDate = CONVERT(NVARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR READ_ONLY FOR  
SELECT name 
FROM master.sys.databases 
WHERE name NOT IN ('master','model','msdb','tempdb')  -- exclude these databases
AND state = 0 -- database is online
AND is_in_standby = 0 -- database is not read only for log shipping
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName
 
   FETCH NEXT FROM db_cursor INTO @name   
END   
 
CLOSE db_cursor   
DEALLOCATE db_cursor


/*
BACKUP DATABASE CapitalManagementStaging TO DISK = N'\\nspinfwcipp01\NetworkOps_Backup_Production\145\CapitalManagementStaging.bak' WITH COPY_ONLY, RETAINDAYS = 0, NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10

BACKUP DATABASE FTTHStaging TO DISK = N'\\nspinfwcipp01\NetworkOps_Backup_Production\145\FTTHStaging.bak' WITH COPY_ONLY, RETAINDAYS = 0, NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10

BACKUP DATABASE MaterialsDevelopment TO DISK = N'\\nspinfwcipp01\NetworkOps_Backup_Production\145\MaterialsDevelopment.bak' WITH COPY_ONLY, RETAINDAYS = 0, NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10

BACKUP DATABASE MaterialsStaging TO DISK = N'\\nspinfwcipp01\NetworkOps_Backup_Production\145\MaterialsStaging.bak' WITH COPY_ONLY, RETAINDAYS = 0, NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
*/