select work_queue_id, wq.employee_number, employee_first_name||' '||employee_last_name name, replace(replace(comments,CHR(13),''),CHR(10),' ') comments     
from work_queue wq,    
     employee emp    
where wq.employee_number = emp.employee_number     
order by 1    
;