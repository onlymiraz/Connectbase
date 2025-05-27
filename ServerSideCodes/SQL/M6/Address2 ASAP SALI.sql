select document_number, SANO||' '||SASD||' '||SASN||' '||SATH address, city, substr(state,1,2) st
from data_ext.asr_sali
where document_number in (
'1979954',
'1986387',
'1986692',
'1986759',
'1987164')
order by 1