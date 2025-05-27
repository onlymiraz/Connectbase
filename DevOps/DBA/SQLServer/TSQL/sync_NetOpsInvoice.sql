use master
GO
alter database [NetOpsInvoiceStaging]
set offline with rollback immediate
RESTORE DATABASE [NetOpsInvoiceStaging]
from disk = '\\nspinfwcipp01\NetworkOps_Backup_Production\DR\CAPINFWWAPV04\NetOpsInvoice.BAK' with recovery,
MOVE 'NetOpsInvoice' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\NetOpsInvoice.mdf',
MOVE 'NetOpsInvoice_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\NetOpsInvoice_log.ldf', replace, stats=5
alter database [NetOpsInvoiceStaging]
set online
