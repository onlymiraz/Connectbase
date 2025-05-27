--RUN IN ASAPPRD   

select state, sum(num) on_time, sum(denom) completed, sum(backlog) past_due
from (
--------------------------------
select state, null num, count(*) denom, null backlog
from (select distinct pon, acna, 
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
select distinct sr.document_number, sr.pon, first_ecckt_id, acna, lata_number lata, asr.npa, 
       max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp   
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.actual_completion_date,'yyyymmdd') = '20160428'    --Current Reporting Month  
  and asr.order_type = 'ASR' 
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M') 
  and t.task_type = 'DD'
  and acna not in ('ZTK','CUS','ZZZ','SNE','XYY')
  and access_provider_serv_ctr_code in ('GT10','GT11')
  group by sr.document_number, sr.pon, first_ecckt_id,acna, lata_number, asr.npa
) where (supp <> 1 or supp is null)
) group by state
--
UNION ALL
--
select state, count(*) num, null denom, null backlog
from (
select pon, acna, DD,
       case when Accept_dt is null then dd_comp
            when Accept_dt <= dd_comp and accept_dt > drec then Accept_dt 
            else dd_comp end Comp_Dt,
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
select distinct sr.pon, acna, trunc(actual_completion_date) dd_comp,
       min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) drec,
       max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD,
       max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
       max(lata_number) keep (dense_rank last order by asr.last_modified_date) lata, 
       max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and to_char(t.actual_completion_date,'yyyymmdd') = '20160428'    --Current Reporting Month  
  and asr.order_type = 'ASR'
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M') 
  and t.task_type = 'DD'
  and acna not in ('ZTK','CUS','ZZZ','SNE','XYY')
  and access_provider_serv_ctr_code in ('GT10','GT11')
group by sr.pon, acna, actual_completion_date
) where (supp <> 1 or supp is null)
) 
where comp_dt <= DD
group by state
--
UNION ALL
--
select state, null num, null denom, count(*) backlog
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
select distinct sr.pon, acna,
       min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
       max(t.actual_completion_date) keep (dense_rank last order by t.last_modified_date) comp,
       max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
       max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD,
       max(lata_number) keep (dense_rank last order by asr.last_modified_date) lata, 
       max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and asr.order_type = 'ASR'
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M') 
  and t.task_type = 'DD'
  and acna not in ('ZTK','CUS','ZZZ','SNE','XYY')
  and access_provider_serv_ctr_code in ('GT10','GT11')
group by sr.pon, acna
)
where accept_dt is null
and comp is null
and (supp <> 1 or supp is null)  
and to_char(dd,'yyyymmdd') <= '20160428'
) group by state
---------------------------------------------------------
)
group by state;



--DETAIL FOR BACKLOG BY DAY  

select distinct docno, pon, acna, act, dd,
       case when lata in ('952') then 'FL'
            when lata in ('722','724','726','728','730','734','738','740','973') then 'CA'
            when lata in ('552','554','558','560','564','566','568','570','961') then 'TX'
            when npa in ('209','213','310','323','408','415','424','530','559','562',
                         '626','661','707','714','760','805','818','909','949','951') then 'CA'
            when npa in ('727','813','863','941') then 'FL'             
            when npa in ('214','281','325','361','409','469','512','682','817','830',
                         '832','903','936','940','956','972','979') then 'TX'
        else 'UNK' end state
from (        
select distinct sr.document_number docno, sr.pon, acna,
       min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
       max(t.actual_completion_date) keep (dense_rank last order by t.last_modified_date) comp,
       max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
       max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD,
       max(lata_number) keep (dense_rank last order by asr.last_modified_date) lata, 
       max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
       max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     task t
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and asr.order_type = 'ASR'
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M') 
  and t.task_type = 'DD'
  and acna not in ('ZTK','CUS','ZZZ','SNE','XYY')
  and access_provider_serv_ctr_code in ('GT10','GT11')
group by sr.document_number, sr.pon, acna
)
where accept_dt is null
and comp is null
and (supp <> 1 or supp is null)  
and to_char(dd,'yyyymmdd') <= '20160428'
order by 1;


--TO ID COMPLETED ORDERS  
select *
from (
select sr.document_number, 
       first_ecckt_id, 
       asr.activity_indicator, 
       acna,
       case when substr(first_ecckt_id,1,2) in ('69','65') then 'FL'
            when substr(first_ecckt_id,1,2) in ('81','45') then 'CA'
            when substr(first_ecckt_id,1,2) in ('12','13') then 'TX'
            else null end state,
       asr.desired_due_date,
       actual_completion_date,
       max(sr.supplement_type) keep (dense_rank last order by sr.last_modified_date) supp
from serv_req sr,
     access_service_request asr,
     task t
where sr.document_number = asr.document_number
  and sr.document_number = t.document_number
  and t.task_type = 'DD'
  and to_char(t.actual_completion_date,'yyyymmdd') = '20160428'
  and access_provider_serv_ctr_code in ('GT10','GT11')
  and asr.order_type = 'ASR'
  and asr.request_type in ('S','E') 
  and asr.activity_indicator in ('N','C','T','M')
  and acna not in ('ZTK','CUS','ZZZ','SNE','XYY')
  group by sr.document_number, first_ecckt_id, asr.activity_indicator, acna,asr.desired_due_date,
       actual_completion_date
 ) where (supp <> '1' or supp is null)
 order by 2;     
