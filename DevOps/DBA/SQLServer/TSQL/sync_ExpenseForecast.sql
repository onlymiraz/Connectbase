use master
GO
alter database [ExpenseForecastStaging]
set offline with rollback immediate
RESTORE DATABASE [ExpenseForecastStaging]
from disk = '\\nspinfwcipp01\NetworkOps_Backup_Production\DR\CAPINFWWAPV04\ExpenseForecast.BAK' with recovery,
MOVE 'ExpenseForecast' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ExpenseForecast.mdf',
MOVE 'ExpenseForecast_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ExpenseForecast_log.ldf', replace, stats=5
alter database [ExpenseForecastStaging]
set online
