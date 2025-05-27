select distinct docno, pon, act, project, drec, dd, ddd, Accept_dt, dd_task_comp_dt, completion_dt,  
       Prod, acna, jeop, jeopardy_reason_description, 
	   state, expedite, status, impcon, 
	   substr(imp_tel_no,1,10) imp_tel_no, asc_ec, actl, cllia, clliz, dd_user_id, VNETRESP_COMP, npanxx
from (
select document_number docno, pon, proj project, drec, dd, ddd, Accept_dt, dd_comp dd_task_comp_dt,  
       Prod, ckt, impcon, imp_tel_no, asc_ec, actl, cllia, clliz, act, 
       acna, jeop, state, expedite,	comp_dt completion_dt,  	
	   case when (comp_dt <= DD or DD is null) then 'Met'
	        when (comp_dt > DD and jeop in ('CU01','CU02','CU03','CU04','CU05','DS02','EX01','CU51','CU52','CU53','DS52')) then 'Met'
	        else 'Miss' end Status, dd_user_id, VNETRESP_COMP, npanxx
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
			when substr(nc,1,1) in ('K') then 'Ethernet-UNI'
			when substr(nc,1,1) in ('V') then 'Ethernet-EVC'
            when substr(nc,1,2) in ('SN') then 'Ethernet-NNI'
			when substr(ckt,4,1) in ('K') then 'Ethernet-UNI'
			when substr(ckt,4,1) in ('V') then 'Ethernet-EVC'
			when ckt like '%/T1%' then 'DS1'
			when ckt like '%/T3%' then 'DS3'
			when proj like 'ATTMOB-TLS%' then 'Ethernet-UNI'
			when proj like 'ATTMOB-EVC%' then 'Ethernet-EVC'
			else ' ' end Prod,		
		pon, icsc, acna, proj, jeop, 
		case when nl2clli is not null then substr(nl2clli,5,2) 
             when nl1clli is not null then substr(nl1clli,5,2)
			 when pri is not null then pri
			 when sec is not null then sec
			 when substr(proj,1,10) in ('ATTMOB-TLS','ATTMOB-EVC') then substr(proj,12,2)
			 else null end state,
		supp, ckt, expedite, impcon, imp_tel_no, asc_ec, actl, nl1clli cllia, nl2clli clliz, 
		act, dd_user_id, VNETRESP_COMP, npa||nxx npanxx
from (
select sr.document_number, 
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
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) nl1clli,
	   max(nl2.clli_code) keep (dense_rank last order by nl2.last_modified_date) nl2clli, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri, 
	   trunc(t.actual_completion_date) DD_COMP,
	   trunc(t2.actual_completion_date) VNETRESP_COMP,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
	   max(expedite_indicator) keep (dense_rank last order by asr.last_modified_date) expedite,
	   de.impcon, de.imp_tel_no, de.asc_ec,
	   max(dlr.ACCESS_CUST_TERMINAL_LOCATION) keep (dense_rank last order by dlr.last_modified_date) ACTL,
	   Max(t.last_modified_userid) keep (dense_rank last order by t.last_modified_date) DD_USER_ID,
	   max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
	   max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx
from asr_user_data aud, 
     access_service_request asr,
	 serv_req sr,
	 network_location nl1,
	 network_location nl2,
	 design_layout_report dlr,
	 task_jeopardy_whymiss jw,
	 task t,
	 task t2,
	 circuit c,
	 data_ext.asr_detail de
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = dlr.document_number (+)
  and sr.document_number = t.document_number
  and sr.document_number = t2.document_number (+)
  and t.task_number = jw.task_number(+)
  and sr.document_number = de.document_number(+)
  and to_char(t.actual_completion_date,'yyyymm') = '202105'    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
  and t2.task_type (+) = 'VNETRESP'
group by sr.document_number, asr.request_type, t.actual_completion_date, de.impcon, de.imp_tel_no, de.asc_ec, t2.actual_completion_date
))
where (supp <> 1 or supp is null) 
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders 
 and (acna not in ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',
                   'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ') or acna is null)
 ) 
 a, jeopardy_type jt
 where a.jeop = jt.jeopardy_reason_code(+)
 and jeopardy_type_cd(+) = 'W' 
order by 9, 1



