select fld_requestid, fld_modifieddate, fld_complete_causecode, fld_complete_faultlocation
from casdw.trouble_ticket_r
where fld_requestid in (
'OP-000002959114')
order by 1,2
 