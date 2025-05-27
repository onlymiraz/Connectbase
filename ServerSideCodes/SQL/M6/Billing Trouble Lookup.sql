--IF YOU HAVE THE OP_ID

select distinct ticket_id, wo_id, clec_id, ckt_id, create_date, cleared_dt,
       case when disp = 'NTF' then 0 else ttr end ttr, cause_cd,
       repair_code, disp, request_type, TROUBLE_DESC
from (       
select distinct ticket_id, wo_id,
       case when acna is not null then acna
            when acna1 is not null then acna1
            when ccna1 is not null then ccna1
            when acna2 is not null then acna2
            else ccna2 end CLEC_ID,        
       ckt_id, create_date, cleared_dt, TTR, cause_cd,
       a.repair_code, b.disp,reqstat, assignmentprofile, request_type, TROUBLE_DESC
from (
select a.fld_requestid ticket_id, 
       max(wo.fld_requestid) keep (dense_rank last order by wo.dw_load_date_time) wo_id,
       a.exchange_carrier_circuit_id ckt_id, 
       replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
       max(trim(a.acna)) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(trim(d.acna)) keep (dense_rank last order by d.last_modified_date) acna1, 
       max(trim(d.ccna)) keep (dense_rank last order by d.last_modified_date) ccna1,
       max(trim(d.acna)) keep (dense_rank first order by d.acna) acna2, 
       max(trim(d.ccna)) keep (dense_rank first order by d.ccna) ccna2,
       max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type,
       max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
       max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
       max(fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) cause_cd,
       max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
       max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
       max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT,
       max(a.fld_alocationaccessname2) location_name,
       max(trim(a.fld_assignmentprofile)) keep (dense_rank first order by a.fld_modifieddate) assignmentprofile,
       max(REPLACE(REPLACE(A.FLD_DESCRIPTIONOFSYMPTON,CHR(10),''),CHR(13),'')) TROUBLE_DESC
from casdw.trouble_ticket_r a,
     casdw.work_order_r wo,  
     casdw.design_layout_report d
where a.fld_requestid = wo.fld_ticketid (+)
 and a.fld_troublereportstate = 'closed'
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.fld_requestid in (
'OP-000003183624',
'OP-000003183616',
'OP-000003183621'
 )
group by a.fld_requestid, a.exchange_carrier_circuit_id
) a, 
  trbl_found_remedy b
where a.repair_code = b.trbl_found_desc (+)
and reqstat = 'Closed'
)
;




--IF YOU HAVE THE WO_ID

select distinct ticket_id, wo_id, clec_id,  ckt_id, create_date, cleared_dt, 
       case when disp = 'NTF' then 0 else ttr end ttr,
       repair_code, disp, reqstat, assignmentprofile, request_type
from (
select distinct ticket_id, wo_id,
       case when acna is not null then acna
            when acna1 is not null then acna1
            when ccna1 is not null then ccna1
            when acna2 is not null then acna2
            else ccna2 end CLEC_ID,        
       ckt_id, create_date, cleared_dt, TTR, a.repair_code, b.disp,reqstat, assignmentprofile, request_type
from (
select a.fld_requestid ticket_id, 
       wo.wo_id,
       a.exchange_carrier_circuit_id ckt_id, 
       replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
       max(trim(a.acna)) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(trim(d.acna)) keep (dense_rank last order by d.last_modified_date) acna1, 
       max(trim(d.ccna)) keep (dense_rank last order by d.last_modified_date) ccna1,
       max(trim(d.acna)) keep (dense_rank first order by d.acna) acna2, 
       max(trim(d.ccna)) keep (dense_rank first order by d.ccna) ccna2,
       max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type,
       max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
       max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
       max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
       max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT,
       max(a.fld_alocationaccessname2) location_name,
       max(trim(a.fld_assignmentprofile)) keep (dense_rank first order by a.fld_modifieddate) assignmentprofile
from (     
select fld_requestid wo_id, fld_ticketid ticket_id 
from casdw.work_order_r
where fld_requestid in (      
'WO-000001445128',
'WO-000001445684'
)) wo,     
  casdw.trouble_ticket_r a,  
  casdw.design_layout_report d
where wo.ticket_id = a.fld_requestid
 and a.fld_troublereportstate = 'closed'
 and a.exchange_carrier_circuit_id = d.ecckt(+)
group by a.fld_requestid, wo.wo_id, a.exchange_carrier_circuit_id
) a, 
  trbl_found_remedy b
where a.repair_code = b.trbl_found_desc (+)
and reqstat = 'Closed'
)
;



select c1,  REGEXP_REPLACE (c800006024,'[[:cntrl:]]*') closeout
from os3.t1074
where c1 in (
'OP-000001827224'
)
;

select * --fld_woid
from casdw.trouble_ticket_r
where fld_requestid = 'OP-000002101300'
--where fld_woid = 'WO-000000838606'
and fld_troublereportstate = 'closed'
;


select fld_requestid,exchange_carrier_circuit_id, fld_startdate 
from casdw.trouble_ticket_r
where substr(exchange_carrier_circuit_id,1,14) in ( 
'13/HCGS/185180',)
order by 2,1;


;


select * --fld_requestid wo, fld_ticketid 
from casdw.work_order_r
where fld_vnet_id in ('35135117')
;


select fld_requestid, REGEXP_REPLACE (fld_complete_viryaneteventnote,'[[:cntrl:]]*')  comp_remarks
from os3.os3_op_request
where fld_requestid in (
'OP-000002081588',
'OP-000002065487')
;

select *
from casdw.trouble_ticket_r
where fld_requestid in (
'OP-000001950630'
)
;

select * --fld_requestid wo, fld_ticketid 
from casdw.work_order_r
where fld_ticketid in (
'OP-000001950630')
;
