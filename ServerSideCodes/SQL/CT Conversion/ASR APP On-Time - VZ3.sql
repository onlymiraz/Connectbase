--Run from ASAPPRD   


select state, sum(denom) due, sum(num) on_time, sum(backlog) backlog
from (
------------------------------
select state, null num, count(*) denom, null backlog
from (
select distinct pon, acna, 
       case when lata in ('952') then 'FL'
            when lata in ('722','724','726','728','730','734','738','740','973') then 'CA'
            when lata in ('552','554','558','560','564','566','568','570','961') then 'TX'
            when npa in ('209','213','310','323','408','415','424','530','559','562',
                         '626','661','707','714','760','805','818','909','949','951') then 'CA'
            when npa in ('727','813','863','941') then 'FL'             
            when npa in ('214','281','325','361','409','469','512','682','817','830',
                         '832','903','936','940','956','972','979') then 'TX'
        else 'CA' end state
from (
select distinct sr.pon, acna, lata_number lata, asr.npa
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.scheduled_completion_date,'yyyymmdd') = '20160430'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and t.task_type = 'APP'
  and sr.acna not in ('ZTK','ZZZ','CUS','SNE','XYY')
  and access_provider_serv_ctr_code in ('GT10','GT11')
))
group by state
------------------------
UNION ALL
------------------------
select state, count(*) num, null denom, null backlog
from (
select distinct pon, acna, compdt,
       case when lata in ('952') then 'FL'
            when lata in ('722','724','726','728','730','734','738','740','973') then 'CA'
            when lata in ('552','554','558','560','564','566','568','570','961') then 'TX'
            when npa in ('209','213','310','323','408','415','424','530','559','562',
                         '626','661','707','714','760','805','818','909','949','951') then 'CA'
            when npa in ('727','813','863','941') then 'FL'             
            when npa in ('214','281','325','361','409','469','512','682','817','830',
                         '832','903','936','940','956','972','979') then 'TX'
        else 'CA' end state
from (
select distinct sr.pon, acna, trunc(actual_completion_date) compdt, lata_number lata, asr.npa
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.scheduled_completion_date,'yyyymmdd') = '20160430'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and t.task_type = 'APP'
  and sr.acna not in ('ZTK','ZZZ','CUS','SNE','XYY')
  and access_provider_serv_ctr_code in ('GT10','GT11')
))
 where to_char(compdt,'yyyymmdd') < = '20160430'
 group by state
-------------------------
UNION ALL
-------------------------
select state, null num, null denom, count(*) backlog
from (
select distinct docno, max(actual_completion_date) keep (dense_rank last order by t.last_modified_date) app_comp, 
       max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop,
       case when lata in ('952') then 'FL'
            when lata in ('722','724','726','728','730','734','738','740','973') then 'CA'
            when lata in ('552','554','558','560','564','566','568','570','961') then 'TX'
            when npa in ('209','213','310','323','408','415','424','530','559','562',
                         '626','661','707','714','760','805','818','909','949','951') then 'CA'
            when npa in ('727','813','863','941') then 'FL'             
            when npa in ('214','281','325','361','409','469','512','682','817','830',
                         '832','903','936','940','956','972','979') then 'TX'
        else 'CA' end state
from (
select distinct sr.document_number docno,lata_number lata, asr.npa
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.scheduled_completion_date,'yyyymmdd') <= '20160430'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and t.task_type = 'APP'
  and (actual_completion_date is null and task_status <> 'Complete')
  and sr.acna not in ('ZTK','ZZZ','CUS','SNE','XYY')
  and access_provider_serv_ctr_code in ('GT10','GT11')
  ) a, 
    task t,
    task_jeopardy_whymiss jw
  where a.docno = t.document_number
  and t.task_number = jw.task_number(+)
  and jw.jeopardy_type_cd(+) = 'J' 
   and t.task_type = 'APP'
  group by docno, lata, npa
)where app_comp is null
group by state
------------------------------------------
)
group by state
order by 1;