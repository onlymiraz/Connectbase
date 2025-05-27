select distinct docno, pon, project, drec, dd, ddd, Accept_dt, dd_task_comp_dt, completion_dt,  
       Prod, acna, jeop, jt.descript Why_Miss_Desc, state, expedite
from (
select document_number docno, pon, proj project, drec, dd, ddd, Accept_dt, dd_comp dd_task_comp_dt,  
       Prod, ckt,
       acna, jeop, state, expedite,	comp_dt completion_dt,  	
	   case when (comp_dt <= DD or DD is null) then 'Met'
	        when (comp_dt > DD and jeop in ('02','05','005','14','17','17H','18','18H','00A','00B','00C','1C','1E','1R')) then 'Met'
	        else 'Miss' end Status
from (
select document_number, trunc(drec) drec, dd, ddd, dd_comp, accept_dt, 
       case when dd_comp is null and accept_dt > drec then Accept_dt
	        when Accept_dt is null then dd_comp
	        when Accept_dt <= dd_comp and accept_dt > drec then Accept_dt 
	        else dd_comp end Comp_Dt, 
	   case when nc = 'HC' then 'DS1'
	        when nc = 'HF' then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
			when nc = 'OB' then 'OC3'
			when nc = 'OD' then 'OC12'
			when nc = 'OF' then 'OC48'
			when nc = 'OG' then 'OC192'
			when substr(nc,1,1) in ('K','V') then 'Ethernet'
			when substr(ckt,4,1) in ('K','V') then 'Ethernet'
			when ckt like '%/T1%' then 'DS1'
			when ckt like '%/T3%' then 'DS3'
			when proj like 'ATTMOB-%' then 'Ethernet'
			else ' ' end Prod,		
		pon, icsc, acna, proj, jeop, 
		case when nl2clli is not null then nl2clli 
             when nl1clli is not null then nl1clli
			 when pri is not null then pri
			 when sec is not null then sec
			 when substr(proj,1,10) in ('ATTMOB-TLS','ATTMOB-EVC') then substr(proj,12,2)
			 else null end state,
		clli_code, supp, ckt, expedite
from (
select aud.document_number, 
       asr.request_type, 
	   max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) proj, 
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) drec, 
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 
	   min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt, 
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 
	   max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,  
	   max(access_provider_serv_ctr_code) icsc, 
	   max(sr.acna) acna,  
	   max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
	   max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop, 
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code, 
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) nl1clli,
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl2.last_modified_date) nl2clli, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri, 
	   trunc(t.actual_completion_date-4/24) DD_COMP,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
	   max(expedite_indicator) keep (dense_rank last order by asr.last_modified_date) expedite
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.network_location nl1,
	 casdw.network_location nl2,
	 casdw.design_layout_report dlr,
	 casdw.task_jeopardy_whymiss jw,
	 casdw.task t,
	 casdw.circuit c
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = dlr.document_number (+)
  and sr.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  and to_char(t.actual_completion_date,'yyyymm') = '201404'    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C')
  and asr.order_type = 'ASR'
  and sr.acna = 'FLR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
group by aud.document_number, asr.request_type, t.actual_completion_date
))
where icsc not in ('RT01','CU03','CZ02')
 and (supp <> 1 or supp is null) 
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders  
 ) a, jeopardy_type jt
 where a.jeop = jt.code(+)
 and status = 'Miss'
order by 8, 1


