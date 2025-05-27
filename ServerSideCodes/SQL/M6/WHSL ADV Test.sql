select aud.document_number, 
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
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code, 
	   max(substr(nl1.clli_code,1,6)) keep (dense_rank last order by nl1.last_modified_date) cllia,
	   max(substr(nl2.clli_code,1,6)) keep (dense_rank last order by nl2.last_modified_date) clliz, 
	   trunc(t.actual_completion_date-4/24) DD_COMP,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
	   max(asr.expedite_indicator) keep (dense_rank last order by asr.last_modified_date) expedite,
	   max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
	   max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx
from whsl_adv_hist.m6_asr_user_data_thist aud, 
     whsl_adv_hist.m6_accs_svc_request_thist asr,
	 whsl_adv_hist.m6_serv_req_thist sr,
	 whsl_adv_hist.m6_ntwk_loc_thist nl1,
	 whsl_adv_hist.m6_ntwk_loc_thist nl2,
	 whsl_adv_hist.m6_task_jeopardy_whymiss_thist jw,
	 whsl_adv_hist.m6_task_thist t,
	 whsl_adv_hist.m6_circuit_thist c
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  and to_char(t.actual_completion_date,'yyyymm') = '201507'    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
group by aud.document_number, asr.request_type, t.actual_completion_date;