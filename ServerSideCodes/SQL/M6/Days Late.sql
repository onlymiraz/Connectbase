select document_number docno, type_of_sr, pon, drec, dd, ddd, Comp_Dt, dd_comp, accept_dt, null comp_week,			
       Prod,			
       icsc, acna, jeop, state	
from (			
select document_number, type_of_sr, trunc(drec) drec, dd, ddd, dd_comp, accept_dt, 			
       case when dd_comp is null and accept_dt > drec then Accept_dt			
	        when Accept_dt is null then dd_comp		
	        when Accept_dt <= dd_comp and accept_dt > drec then Accept_dt 		
	        else dd_comp end Comp_Dt, 		
	   case when rate in ('DS0','DS1','DS3','OC3','OC12','OC48') then rate
	        when nc = 'HC' then 'DS1'
	        when substr(first_ckt,4,2) in ('HC','IP','DH','UH','YB') then 'DS1' 		
	        when nc = 'HF' then 'DS3'		
			when substr(first_ckt,4,2) = 'HF' then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
			when substr(first_ckt,4,1) in ('L','X') then 'DS0'
			when substr(first_ckt,4,2) in ('FX','UG','TY','SX','AR') then 'DS0' 
			when nc = 'OB' then 'OC3'
			when nc = 'OD' then 'OC12'
			when nc = 'OF' then 'OC48'
			when nc = 'OG' then 'OC192'
			when substr(nc,1,1) in ('K','V') then 'Ethernet'
			when substr(first_ckt,4,1) in ('K','V') then 'Ethernet'
			when proj like 'ATTMOB-%' then 'Ethernet'
			else rate end Prod,
		pon, icsc, acna, proj, jeop, 	
	   case when clliz_state is not null then clliz_state
		    when cllia_state is not null then cllia_state
            when pri is not null then pri			
			when sec is not null then sec
			when proj like 'ATTMOB-%' then substr(proj,12,2)
			else null end state,
		clli_code, supp, first_ckt	
from (		
select sr.document_number, 			
       sr.request_type, 
	   sr.type_of_sr,			
	   max(sr.project_identification) keep (dense_rank last order by sr.last_modified_date) proj, 		
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) drec, 			
	   max(sr.desired_due_date) keep (dense_rank last order by sr.last_modified_date) DD, 		
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 		
	   min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt, 		
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 		
	   max(sr.pon) keep (dense_rank last order by sr.last_modified_date) pon,  		
	   max(access_provider_serv_ctr_code) icsc, 		
	   max(sr.acna) acna,  		
	   max(sr.activity_ind) keep (dense_rank last order by sr.last_modified_date) act, 		
	   max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop,  		
	   substr(max(nl1.clli_code),5,2) cllia_state,
	   substr(max(nl2.clli_code),5,2) clliz_state,
	   max(nl2.clli_code) clli_code, 		
	   max(secloc_state) sec, 		
	   max(priloc_state) pri, 
	   max(c.rate_code) keep (dense_rank last order by c.last_modified_date) rate,		
	   trunc(t.actual_completion_date) DD_COMP,		
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,		
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) first_ckt		
from casdw.serv_req sr, 			
     casdw.access_service_request asr,			
	 casdw.asr_user_data aud,
	 casdw.circuit c,		
	 casdw.network_location nl1,
	 casdw.network_location nl2,
	 casdw.design_layout_report dlr,		
	 casdw.task_jeopardy_whymiss jw,		
	 casdw.task t
where sr.document_number = asr.document_number(+)			
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id(+)
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = dlr.document_number (+)			
  and sr.document_number = t.document_number(+)			
  and t.task_number = jw.task_number(+)			
  and to_char(t.actual_completion_date,'yyyymm') = '201205'    --Current Reporting Month  			
  and (sr.request_type in ('S','E') or sr.request_type is null)			
  and sr.activity_ind in ('N','C')			
  --and sr.type_of_sr in ('ASR','SO')			
  and jw.jeopardy_type_cd(+) = 'W' 			
  and t.task_type = 'DD'	  	
group by sr.document_number, asr.request_type, t.actual_completion_date, sr.type_of_sr			
))	
where (supp <> 1 or supp is null)			
 and (acna <> 'ZTK' or acna is null)			
order by 7,1