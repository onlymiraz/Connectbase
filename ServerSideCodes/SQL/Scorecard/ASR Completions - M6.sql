   
	   
select sum(num) on_time, sum(denom) completed
from (
--
select null num, count(*) denom
from (
select distinct sr.pon
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.scheduled_completion_date,'yyyymmdd') = '20141010'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and t.task_type = 'APP'
  and access_provider_serv_ctr_code = 'FV01'
)
--
UNION ALL
--
select count(*) num, null denom
from (
select distinct sr.pon, trunc(actual_completion_date) dt
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.scheduled_completion_date,'yyyymmdd') = '20141010'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and t.task_type = 'APP'
  and access_provider_serv_ctr_code = 'FV01'
)
 where to_char(dt,'yyyymmdd') < = '20141010'
)






