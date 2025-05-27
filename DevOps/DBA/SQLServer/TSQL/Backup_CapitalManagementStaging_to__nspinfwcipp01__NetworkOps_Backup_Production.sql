BACKUP DATABASE CapitalManagementStaging TO DISK = N'\\nspinfwcipp01\NetworkOps_Backup_Production\145\CapitalManagementStaging.bak' WITH COPY_ONLY, RETAINDAYS = 0, NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10

BACKUP DATABASE FTTHStaging TO DISK = N'\\nspinfwcipp01\NetworkOps_Backup_Production\145\FTTHStaging.bak' WITH COPY_ONLY, RETAINDAYS = 0, NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10

BACKUP DATABASE MaterialsDevelopment TO DISK = N'\\nspinfwcipp01\NetworkOps_Backup_Production\145\MaterialsDevelopment.bak' WITH COPY_ONLY, RETAINDAYS = 0, NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10

BACKUP DATABASE MaterialsStaging TO DISK = N'\\nspinfwcipp01\NetworkOps_Backup_Production\145\MaterialsStaging.bak' WITH COPY_ONLY, RETAINDAYS = 0, NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10