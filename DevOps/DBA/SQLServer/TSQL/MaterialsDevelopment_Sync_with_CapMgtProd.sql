USE master
GO
alter database MaterialsDevelopment
set offline with rollback immediate
RESTORE DATABASE MaterialsDevelopment
from disk = 'D:\Backup_Prod\CapitalManagementProduction_backup_2022_06_30_000001_5670178.bak' with recovery,
MOVE 'CapitalManagementProduction' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\MaterialsDevelopment.mdf',
MOVE 'CapitalManagementProduction_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\MaterialsDevelopment_log.ldf', replace, stats=5
alter database MaterialsDevelopment
set online

/*
USE MaterialsDevelopment
GO
ALTER ROLE [db_owner] ADD MEMBER sql_NetOpsStaging
GO
*/