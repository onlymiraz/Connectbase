select document_number, ticket_id, create_dt,
case when to_char(Cleared_Dt,'yyyymmdd') between '20131103' and '20140309' then Cleared_dt-5/24
	        else Cleared_dt-4/24 end Cleared_Dt, 
case when to_char(Closed_Dt,'yyyymmdd') between '20131103' and '20140309' then Closed_dt-5/24
	        else Closed_dt-4/24 end Closed_Dt,
ttr, a.trbl_found_id, trbl_desc
from (
select document_number, ticket_id, 
max(a.CREATE_DATE) keep (dense_rank last order by a.last_modified_date) CREATE_DT,
max(a.CLEARED_DT) keep (dense_rank last order by a.last_modified_date) CLEARED_DT, 
max(a.CLOSE_DT) keep (dense_rank last order by a.last_modified_date) CLOSED_DT,  
max(round(a.ttr/3600,2)) keep (dense_rank last order by a.last_modified_date) ttr, 
max(a.TRBL_FOUND_ID) keep (dense_rank last order by a.last_modified_date) trbl_found_id,
max(a.TROUBLE_desc) keep (dense_rank last order by a.last_modified_date) trbl_desc
from casdw.trouble_ticket a
where serv_item_desc like '30/HCFS/500063%'
and current_state = 'closed'
group by document_number, ticket_id
) a, casdw.trouble_found_type tft
where a.trbl_found_id = tft.trbl_found_id(+)

