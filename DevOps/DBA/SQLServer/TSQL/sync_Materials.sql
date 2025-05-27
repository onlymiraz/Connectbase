use master
GO
alter database MaterialsStaging
set offline with rollback immediate
RESTORE DATABASE MaterialsStaging
from disk = '\\nspinfwcipp01\NetworkOps_Backup_Production\DR\144\CapitalManagementProduction.bak' with recovery,
MOVE 'CapitalManagementProduction' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\MaterialsStaging.mdf',
MOVE 'CapitalManagementProduction_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\MaterialsStaging_log.ldf', replace, stats=5
alter database MaterialsStaging
set online

/*
USE MaterialsStaging
GO
ALTER ROLE [db_owner] ADD MEMBER sql_NetOpsStaging
GO
*/