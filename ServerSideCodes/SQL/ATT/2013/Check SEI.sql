
select document_number, eusa_sec_sei, transport_sei
from data_ext.asr_detail
where document_number in (
'2235961',
'2236584',
'2247679',
'2257129',
'2259950',
'2262899'
);



If SEI = Y then POP to Switch
If SEI is blank then POP to Prem