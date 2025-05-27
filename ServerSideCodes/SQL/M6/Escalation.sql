--The Create Date, Cleared Date and Close Date are stored in GMT.   

select distinct ticket_id, 
       case when substr(circuit,1,2) in ('R2','r2') then 'NY'
			when site_state is not null and site_id <> 'NON INVENTORIED CIRCUIT'
	         and site_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then site_state
			when substr(circuit,1,2) in ('T-','t-','T1','t1','T3','t3') then 'NY' 
			when ckt_id like '%/WV%' then 'WV'
		    when substr(circuit,1,2) in ('50','54','56') then 'WV'
            else null end state,
       acna, ckt_id,  
	   TO_CHAR(TO_DATE('01/01/1970:000000', 'MM/DD/YYYY  HH24:MI:SS')+((create_date-18000) /(60*60*24)),'MM/DD/YYYY  HH24:MI:SS') create_dt,
	   TO_CHAR(TO_DATE('01/01/1970:000000', 'MM/DD/YYYY  HH24:MI:SS')+((cleared_dt-18000) /(60*60*24)),'MM/DD/YYYY  HH24:MI:SS') cleared_dt,
	   TO_CHAR(TO_DATE('01/01/1970:000000', 'MM/DD/YYYY  HH24:MI:SS')+((closed_dt-18000) /(60*60*24)),'MM/DD/YYYY  HH24:MI:SS') closed_dt,
	   TTR, repair_code, escalation_level, escalation_org_level_int, escalation_org_level_txt, escalation_person, escalation_phone,
	   TO_CHAR(TO_DATE('01/01/1970:000000', 'MM/DD/YYYY  HH24:MI:SS')+((escalation_request_date-18000) /(60*60*24)),'MM/DD/YYYY  HH24:MI:SS') escalation_request_date
from (
select a.fld_requestid ticket_id, 
       max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
	   replace(replace(a.exchange_carrier_circuit_id, chr(10)),chr(13)) ckt_id, 
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
	   max(trim(a.acna)) keep (dense_rank last order by a.fld_modifieddate) acna,
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type,
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
	   max(fld_escalationlevel) keep (dense_rank last order by a.fld_modifieddate) escalation_level, 
	   max(fld_escalationorglevelint) keep (dense_rank last order by a.fld_modifieddate) escalation_org_level_int, 
	   max(fld_escalationorgleveltxt) keep (dense_rank last order by a.fld_modifieddate) escalation_org_level_txt, 
       max(fld_escalationperson) keep (dense_rank last order by a.fld_modifieddate) escalation_person, 
	   max(fld_escalationphone) keep (dense_rank last order by a.fld_modifieddate) escalation_phone, 
	   max(fld_escalationreason) keep (dense_rank last order by a.fld_modifieddate) escalation_reason,
	   max(fld_escalationrequestdate) keep (dense_rank last order by a.fld_modifieddate) escalation_request_date 
from os3.os3_op_request a
where a.fld_troublereportstate = 'closed'
  and a.fld_requeststatus = 'Closed'
  and a.fld_assignmentprofile = 'CNOC'
  and TO_CHAR(TO_DATE('197001', 'YYYYMM')+((fld_event_end_time-18000) /(60*60*24)),'YYYYMM') = '201502'    ----CHANGE THIS DATE EACH MONTH   
group by a.fld_requestid, a.exchange_carrier_circuit_id
)
where escalation_level > 0
order by 7



