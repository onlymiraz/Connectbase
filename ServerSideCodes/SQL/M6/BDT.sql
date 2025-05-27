select n.document_number, sr.pon, trunc(n.date_entered) date_entered, substr(REGEXP_REPLACE (n.note_text,'[[:cntrl:]]*'),1,150) note_text
from notes n, serv_req sr
where n.document_number = sr.document_number
and n.note_text like ('%PHASE 4%Per%')
and sr.document_number in (
'2921257')
order by 1,3;
