   
	   
select sum(denom) due, sum(num) on_time, sum(backlog) backlog
from (
------------------------------
select null num, count(*) denom, null backlog
from (
select distinct sr.pon, acna
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.scheduled_completion_date,'yyyymmdd') = '20141121'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and t.task_type = 'APP'
  and sr.acna not in ('ZTK','ZZZ','CUS','SNE','XYY')
  and access_provider_serv_ctr_code = 'SN01'
)
------------------------
UNION ALL
------------------------
select count(*) num, null denom, null backlog
from (
select distinct sr.pon, trunc(actual_completion_date) compdt
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.scheduled_completion_date,'yyyymmdd') = '20141121'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and t.task_type = 'APP'
  and sr.acna not in ('ZTK','ZZZ','CUS','SNE','XYY')
  and access_provider_serv_ctr_code = 'SN01'
)
 where to_char(compdt,'yyyymmdd') < = '20141121'
-------------------------
UNION ALL
-------------------------
select null num, null denom, count(*) backlog
from (
select docno, max(actual_completion_date) keep (dense_rank last order by t.last_modified_date) app_comp, 
       max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop
from (
select distinct sr.document_number docno
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.scheduled_completion_date,'yyyymmdd') <= '20141121'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and t.task_type = 'APP'
  and (actual_completion_date is null and task_status <> 'Complete')
  and sr.acna not in ('ZTK','ZZZ','CUS','SNE','XYY')
  and access_provider_serv_ctr_code = 'SN01'
  ) a, 
    casdw.task t,
	casdw.task_jeopardy_whymiss jw
  where a.docno = t.document_number
  and t.task_number = jw.task_number(+)
  and jw.jeopardy_type_cd(+) = 'J' 
   and t.task_type = 'APP'
  group by docno 
)where app_comp is null 
) 
  
  
  
  
  
  
