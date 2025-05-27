--If no Submit or Conf data is there, run this on ASAP 

select sr.pon, trunc(min(nts.date_entered)) init_asr, trunc(min(nts.date_entered)) first_clean, trunc(min(nts.date_entered)) clean_asr,
       trunc(t.actual_completion_date) init_conf, trunc(t.actual_completion_date) clean_conf, aud.crdd             
from notes nts, task t, serv_req sr, asr_user_data aud          
where sr.document_number = nts.document_number            
  and sr.document_number = t.document_number          
  and sr.document_number = aud.document_number
and t.task_type = 'ASR-CONF'            
and sr.pon in (            
'181422203INN000C',
'181422203INN000D',
'GO358304-03CHG',
'GO358304-04CHG',
'GO358304-23CHG',
'GO358304-35CHG',
'GO358304-24CHG'            
)            
group by sr.pon, actual_completion_date, aud.crdd             
order by 1            
;            


select * from asr_user_data
where document_number = '3527921'