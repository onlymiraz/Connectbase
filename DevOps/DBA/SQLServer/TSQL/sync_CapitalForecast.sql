use master
GO
alter database CapitalForecastStaging
set offline with rollback immediate
RESTORE DATABASE CapitalForecastStaging
from disk = '\\nspinfwcipp01\NetworkOps_Backup_Production\144\CapitalForecast__2023-11-26_23-00-01.5633333.BAK' with recovery,
MOVE 'CapitalForecast' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\CapitalForecast.mdf',
MOVE 'CapitalForecast_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\CapitalForecast_log.ldf', replace, stats=5
alter database CapitalForecastStaging
set online
