-- On ASAP - run if missing all CONF data  

select sr.pon, trunc(min(nts.date_entered)) receipt_dt, trunc(t.actual_completion_date) conf_dt             
from notes nts, task t, serv_req sr            
where sr.document_number = nts.document_number            
  and sr.document_number = t.document_number             
and t.task_type = 'ASR-CONF'            
and sr.pon in (            
'HWSC3851344'            
)            
group by sr.pon, actual_completion_date            
order by 1            
;         