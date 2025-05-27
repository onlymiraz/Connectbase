
select fld_requestid, fld_startdate, fld_event_end_time, round(fld_mttrepair/3600,2) ttr, fld_complete_repaircode, fld_requesttype
from casdw.trouble_ticket_r
where fld_requestid in ('OP-000001059720','OP-000001069329')
and fld_requeststatus = 'Closed'
;
