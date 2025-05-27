select case when state in ('IL','OH') and substr(icsc,1,2) = 'FV' then 'F9 Central'
            when state in ('CA','OR','WA') and substr(icsc,1,2) = 'FV' then 'F9 West'
			when state in ('AZ','ID','NV','WI') and substr(icsc,1,2) = 'FV' then 'F9 National'
	   else 'Other' end region,
       cleanasr, comp_dt
from (
select document_number docno, pon, cleanasr, dd, ddd, Comp_Dt,dd_comp, accept_dt, 
       Prod,
       icsc, acna, state 		
from (
select document_number, cleanasr, dd, ddd, dd_comp, accept_dt, 
       case when dd_comp is null and accept_dt > cleanasr then Accept_dt
	        when Accept_dt is null then dd_comp
	        when Accept_dt <= dd_comp and accept_dt > cleanasr then Accept_dt 
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
		pon, icsc, acna, proj, 
		case when state is not null then state 
            when pri is not null then pri
			when sec is not null then sec
			when icsc = 'FV01' then 'WV'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '31' then 'IN'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '30' then 'IL'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '33' then 'MI'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '36' then 'OH'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '39' then 'WI'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '85' then 'OR'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '86' then 'WA'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '83' then 'ID'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '61' then 'NC'
			when substr(icsc,1,2) = 'FV' and substr(first_ckt,1,2) = '62' then 'SC'
			when proj like 'ATTMOB-%' then substr(proj,12,2)
			else sec end state,			
		cllicd, supp, first_ckt
from (	
select aud.document_number, 
       asr.request_type, 
	   max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) proj, 
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) cleanasr, 
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 
	   min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt, 
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 
	   max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,  
	   max(access_provider_serv_ctr_code) icsc, 
	   max(sr.acna) acna,  
	   max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
	   substr(max(clli_code),5,2) state, 
	   max(clli_code) cllicd, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri, 
	   trunc(t.actual_completion_date) DD_COMP,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) first_ckt
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.network_location nl,
	 casdw.design_layout_report dlr,
	 casdw.task t
where aud.document_number = asr.document_number
  and aud.document_number = sr.document_number(+)
  and asr.location_id = nl.location_id(+)
  and aud.document_number = dlr.document_number (+)
  and aud.document_number = t.document_number
  and to_char(t.actual_completion_date,'yyyymmdd') = '20120410'    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M')
  and asr.order_type = 'ASR' 
  and t.task_type = 'DD'
group by aud.document_number, asr.request_type, t.actual_completion_date
)
)
where icsc not in ('RT01','CU03','CZ02')
and (supp <> 1 or supp is null) 
 and substr(first_ckt,7,1) <> 'U'  -- Removes UNE Orders  
  )
order by 1

