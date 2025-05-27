   
	   
select sum(num) on_time, sum(denom) completed, sum(backlog) past_due
from (
--
select null num, count(*) denom, null backlog
from (
select distinct sr.pon, acna, 
       max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp   
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.actual_completion_date,'yyyymmdd') = '20141121'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M') 
  and t.task_type = 'DD'
  and acna not in ('ZTK','CUS','ZZZ','SNE','XYY')
  and access_provider_serv_ctr_code = 'SN01'
  group by sr.pon, acna
) where (supp <> 1 or supp is null)
--
UNION ALL
--
select count(*) num, null denom, null backlog
from (
select pon, acna, DD,
       case when Accept_dt is null then dd_comp
	        when Accept_dt <= dd_comp and accept_dt > drec then Accept_dt 
	        else dd_comp end Comp_Dt	
from (	
select distinct sr.pon, acna, trunc(actual_completion_date) dd_comp,
       min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
	   max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) drec,
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.actual_completion_date,'yyyymmdd') = '20141121'    --Current Reporting Month  
  and asr.order_type = 'ASR'
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M') 
  and t.task_type = 'DD'
  and acna not in ('ZTK','CUS','ZZZ','SNE','XYY')
  and access_provider_serv_ctr_code = 'SN01'
group by sr.pon, acna, actual_completion_date
) where (supp <> 1 or supp is null)
)
where comp_dt <= DD
--
UNION ALL
--
select null num, null denom, count(*) backlog
from (
select distinct sr.pon, acna,
       min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
	   max(t.actual_completion_date) keep (dense_rank last order by t.last_modified_date) comp,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and asr.order_type = 'ASR'
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M') 
  and t.task_type = 'DD'
  and acna not in ('ZTK','CUS','ZZZ','SNE','XYY')
  and access_provider_serv_ctr_code = 'SN01'
group by sr.pon, acna
)
where accept_dt is null
and comp is null
and (supp <> 1 or supp is null)  
and to_char(dd,'yyyymmdd') <= '20141121'
)


