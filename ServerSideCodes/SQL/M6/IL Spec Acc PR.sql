select distinct state, pon, document_number, ckt, act, acna, 
	   case when acna = 'ATX' then 'ATT COMMUNICATIONS'
	        when acna in ('AWL','ADM','IUW','SBM') then 'ATT MOBILITY'
	        when acna in ('EBA','GMT','PPM','CCQ') then 'VERIZON WIRELESS'
			when acna in ('MCI','MPL') then 'VERIZON BUSINESS'
			when acna = 'AJF' then 'AERO COMMUNICATIONS'
			when acna = 'CDL' then 'CELLULAR ONE'
			when acna = 'DLV' then 'DELTA COMMUNICATIONS'
			when acna = 'UTC' then 'SPRINT'
			when acna in ('MJC','NLZ') then 'SPRINT PCS'
			when acna = 'WCG' then 'T-MOBILE'
			when acna = 'WIJ' then 'ALLIED WIRELESS'
			when acna = 'UCU' then 'US CELLULAR'
			when acna = 'MHV' then 'AMPS CELLULAR'
			else 'CHECK' end Carrier,
	   product, icsc, drec, dd, ddd, comp_dt, jeop, 
       case when (comp_dt <= DD or DD is null) then 'Met'
	        when substr(jeop,1,2) = 'CU' then 'Met'
			when (comp_dt > DD and jeop in ('CU01','CU02','CU03','CU04','CU05','DS02','CA22','EX01','CU51','CU52','CU53','DS52')) then 'Met'
	        else 'Miss' end status,
       to_char(dd_comp,'YYYYMM') mon     
from (
select document_number, pon, trunc(drec) drec, dd, ddd, dd_comp, accept_dt, 
       case when dd_comp is null and accept_dt > drec then Accept_dt
	        when Accept_dt is null then dd_comp
	        when Accept_dt <= dd_comp and accept_dt > drec then Accept_dt 
	        else dd_comp end Comp_Dt, 
	   case when nc = 'HC' then 'DS1'
	        when nc = 'HF' then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
			when nc in ('OB','OD','OF','OG') then 'OCN'
			else 'N/A' end product,
	   acna, act, jeop, ckt, icsc,
       case when clliz is not null then clliz
            else cllia end state
from (
select sr.document_number, 
       asr.request_type, 
	   max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) project, 
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
	   trunc(t.actual_completion_date) DD_COMP,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(c.exchange_carrier_circuit_id) keep (dense_rank last order by c.last_modified_date) ckt
from asr_user_data aud, 
     access_service_request asr,
	 serv_req sr,
	 network_location nl1,
	 network_location nl2,
	 task_jeopardy_whymiss jw,
	 task t,
	 circuit c,
	 asap.service_request_circuit src
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  and sr.document_number = src.document_number
  AND src.circuit_design_id = c.circuit_design_id
  and to_char(t.actual_completion_date,'yyyymm') = '201805'    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
  and substr(access_provider_serv_ctr_code,1,2) = 'FV'
  and substr(c.exchange_carrier_circuit_id,6,2) = 'FS'
group by sr.document_number, asr.request_type, t.actual_completion_date
)
where (supp <> 1 or supp is null) 
 and (clliz = 'IL' or cllia = 'IL') 
 and (acna not in ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',
                   'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ') or acna is null)
)
order by 1,12;			   




