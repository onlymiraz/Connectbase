
select region, dd_status, count(*)
from (	
select document_number docno, pon, drec, dd, ddd, Comp_Dt,dd_comp, accept_dt, 
       Prod, first_ckt,
       icsc, acna, jeop, state,
	   case when state in ('IL','OH','MN','MO') then 'Central'
	        when state in ('NY','PA') then 'Northeast'
			when state in ('WA','CA','OR') then 'West'
            when state in ('MI','IN','KY') then 'Midwest'
			when state in ('WV','SC','NC','MD') then 'Southeast'
            else 'National' end region, 		
	   case when (comp_dt <= DD or DD is null) then 'Met'
	        when (comp_dt > DD and jeop in ('2','5','14','17','18','55','64')) then 'Met'
	        else 'Miss' end DD_Status
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
			when proj like 'ATTMOB-%' then 'Ethernet'
			else ' ' end Prod,		
		pon, icsc, acna, proj, jeop, 
	   case when clliz is not null then clliz
		    when cllia is not null then cllia
            when pri is not null then pri
			else sec end state,
		cllicd, supp, first_ckt
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
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) cllia,
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl2.last_modified_date) clliz, 
	   max(nl1.clli_code) cllicd, 
	   max(secloc_state) keep (dense_rank last order by asr.last_modified_date) sec, 
	   max(priloc_state) pri, 
	   trunc(t.actual_completion_date) DD_COMP,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) first_ckt
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
  and to_char(t.actual_completion_date,'yyyymmdd') = '20120507'    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
group by sr.document_number, asr.request_type, t.actual_completion_date
))
where icsc not in ('RT01','CU03','CZ02')
 and (supp <> 1 or supp is null) 
 and substr(first_ckt,7,1) <> 'U'  -- Removes UNE Orders  
 )
 group by region, dd_status
order by 1


