use master
GO
alter database [FTTHStaging]
set offline with rollback immediate
RESTORE DATABASE [FTTHStaging]
from disk = '\\nspinfwcipp01\NetworkOps_Backup_Production\DR\144\FTTH.BAK' with recovery,
MOVE 'FTTH' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\FTTH.mdf',
MOVE 'FTTH_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\FTTH_log.ldf', replace, stats=5
alter database [FTTHStaging]
set online
