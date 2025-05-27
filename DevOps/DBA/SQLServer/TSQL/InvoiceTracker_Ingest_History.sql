use NetOpsInvoiceStaging

truncate table [webapp].[InvoiceTracker]

bulk insert [webapp].[InvoiceTracker]
from '\\CAPINFWWWPV01\DataDump\InvoiceTracker_Ingest_History.txt'
with (
--Rowterminator = '\r\n',
--codepage=65001,
--fieldterminator='\t',
FIRSTROW=2
--,batchsize=500
--,format='csv'
--,fieldquote='"'
)

update [webapp].[InvoiceTracker]
set Remarks=replace(Remarks,'"','')
,Invoice_Number=STUFF(Invoice_Number,1,1,'')