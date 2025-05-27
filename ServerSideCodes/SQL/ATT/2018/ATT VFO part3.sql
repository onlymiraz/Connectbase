select sr.pon, trunc(min(nts.date_entered)) init_asr, trunc(min(nts.date_entered)) first_clean, trunc(min(nts.date_entered)) clean_asr,
       trunc(t.actual_completion_date) init_conf, trunc(t.actual_completion_date) clean_conf             
from notes nts, task t, serv_req sr            
where sr.document_number = nts.document_number            
  and sr.document_number = t.document_number             
and t.task_type = 'ASR-CONF'            
and sr.pon in (            
'HWSC3850079'            
)            
group by sr.pon, actual_completion_date            
order by 1            
;            
