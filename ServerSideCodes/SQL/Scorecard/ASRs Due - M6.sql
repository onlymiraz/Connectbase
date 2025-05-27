
select region, status, count(*)
from (
select case when state in ('IL','OH') and substr(icsc,1,2) = 'FV' then 'F9 Central'
            when state in ('CA','OR','WA') and substr(icsc,1,2) = 'FV' then 'F9 West'
			when state in ('AZ','ID','NV','WI') and substr(icsc,1,2) = 'FV' then 'F9 National'
	   else 'Other' end region,
	   status
from (
select document_number, req, order_type, act, trunc(drec) drec, trunc(dd) dd, ddd, dd_comp comp_dt, nc, 
       case when nc = 'HC' then 'DS1'
	        when nc = 'HF' then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
			when nc = 'OB' then 'OC3'
			when nc = 'OD' then 'OC12'
			when nc = 'OF' then 'OC48'
			when nc = 'OG' then 'OC192'
			when substr(nc,1,1) in ('K','V') then 'Ethernet'
			when substr(ckt,4,1) in ('K','V') then 'Ethernet'
			when proj like '%EVC%' then 'Ethernet'
			else ' ' end prod,   
	   pon, ckt, icsc, acna,
	   jeop,
	   proj,
	   case when state is not null then state 
            when icsc = 'FV01' then 'WV'
			when pri is not null then pri
			when sec is not null then sec
			when substr(proj,12,2) = 'NY' then 'NY'
			when substr(proj,12,2) = 'WV' then 'WV'
			when substr(proj,12,2) = 'NC' then 'NC'
			when substr(proj,12,2) = 'IN' then 'IN'
			when substr(proj,12,2) = 'MI' then 'MI'
			when substr(proj,12,2) = 'PA' then 'PA'
			end state,
	   case when dd_comp is not null and dd_comp <= trunc(dd) then 'comp ontime'
	        when dd_comp is not null and dd_comp > trunc(dd) then 'comp late'
	        when dd_comp is null and jeop in ('2','5','14','17','18','55','64') then 'pend CNR'
			else 'past due' end status 		
from (	
select document_number,
       req, 
	   max(order_type) keep (dense_rank last order by asr) order_type,
	   max(project_identification) proj,
	   max(first_ecckt_id) keep (dense_rank last order by sr) ckt,
       min(date_received) drec, 
	   max(desired_due_date) keep (dense_rank last order by asr) DD, 
	   max(crdd) keep (dense_rank last order by aud) DDD, 
	   trunc(actual_completion_date) DD_COMP, 
	   max(network_channel_service_code) nc, 
	   max(pon) pon,  
	   max(access_provider_serv_ctr_code) icsc, 
	   max(acna) acna,  
	   max(activity_indicator) act, 
	   max(jeopardy_reason_code) keep (dense_rank last order by jw) jeop, 
	   max(st) state, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri,
	   max(supplement_type) keep (dense_rank last order by asr) supp
from (
select aud.document_number, asr.order_type,
       asr.request_type req, sr.first_ecckt_id, asr.date_received, asr.desired_due_date, aud.crdd, t.actual_completion_date,
	   asr.pon, access_provider_serv_ctr_code, sr.acna, asr.activity_indicator, asr.supplement_type, substr(clli_code,5,2) st, 
	   asr.network_channel_service_code, jeopardy_reason_code, secloc_state, priloc_state, asr.project_identification, 
	   asr.last_modified_date asr, aud.last_modified_date aud, sr.last_modified_date sr, jw.last_modified_date jw
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.network_location nl,
	 casdw.design_layout_report dlr,
	 casdw.task_jeopardy_whymiss jw,
	 casdw.task t
where aud.document_number = asr.document_number
  and aud.document_number = sr.document_number(+)
  and asr.location_id = nl.location_id(+)
  and aud.document_number = dlr.document_number (+)
  and aud.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  and t.task_type = 'DD'
  and aud.document_number in 
  (
select distinct aud.document_number
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.network_location nl,
	 casdw.design_layout_report dlr,
	 casdw.task_jeopardy_whymiss jw,
	 casdw.task t
where aud.document_number = asr.document_number
  and aud.document_number = sr.document_number(+)
  and asr.location_id = nl.location_id(+)
  and aud.document_number = dlr.document_number (+)
  and aud.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  and to_char(asr.desired_due_date,'YYYYMMDD') = '20120410'     --previous workday    
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M')
  and asr.order_type = 'ASR'
  and t.task_type = 'DD'
))  
group by document_number, req, actual_completion_date
 )
where icsc not in ('RT01','CU03','CZ02') 
and (supp <> 1 or supp is null)
 and to_char(DD,'yyyymmdd') = '20120410'      --previous workday    
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders  
))
group by region, status
order by 1,2
