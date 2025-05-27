select first_ecckt_id, 
       max(ban) keep (dense_rank last order by aud.last_modified_date) ban, 
	   acna
from casdw.serv_req sr,
     casdw.asr_user_data aud
where sr.document_number = aud.document_number
and project_identification like 'ATTMOB-TLS%'
group by first_ecckt_id, acna
order by 1
