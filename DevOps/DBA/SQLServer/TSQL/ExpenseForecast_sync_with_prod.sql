use master
GO
alter database ExpenseForecastStaging
set offline with rollback immediate
RESTORE DATABASE ExpenseForecastStaging
from disk = '\\nspinfwcipp01\NetworkOps_Backup_Production\145\CapitalManagementStaging__2022-10-07_04-00-00.3200000.bak' with recovery,
MOVE 'CapitalManagementProduction' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ExpenseForecastStaging.mdf',
MOVE 'CapitalManagementProduction_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ExpenseForecastStaging_log.ldf', replace, stats=5

alter database ExpenseForecastStaging
set online