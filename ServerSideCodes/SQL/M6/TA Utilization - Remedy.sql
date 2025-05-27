drop table tautilization
/


create table tautilization nologging nocache as
select distinct ticket_id, state, clec_id, ckt_id, customer_ticket_id, create_date, 
       case when cleared_dt is null then closed_dt else cleared_dt end cleared_dt, 
       case when closed_dt is null then cleared_dt else closed_dt end closed_dt, 
	   cl.customer, fld_submitter, assignprofile,
	   case when fld_submitter in ('VFOI','$USER$') then 1 else 0 end electronic
from (
select distinct ticket_id, 
       case when icsc = 'RT01' then 'NY'
	        when substr(circuit,1,2) = 'R2' then 'NY'
	   		when clliz is not null 
			 and clliz in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then clliz
			when site_state is not null and site_id <> 'NON INVENTORIED CIRCUIT'
	         and site_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then site_state 
	        when cllia is not null 
			 and cllia in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then cllia
            when priloc is not null 
			 and priloc in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then priloc
		    when icsc = 'FV01' then 'WV'
			when ckt_id like '%/WV%' then 'WV'
		    when substr(circuit,1,2) in ('50','54','56') then 'WV'
            else null end state,
       case when acna is not null then acna
	        when acna1 is not null then acna1
	        when ccna1 is not null then ccna1
			when acna2 is not null then acna2
            else ccna2 end CLEC_ID,	
	   create_date, 
	   case when Cleared_Dt is not null then Cleared_dt
            else Closed_dt end Cleared_Dt, 
	   case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,      			
       ckt_id, fld_submitter, customer_ticket_id, assignprofile
from (
select ticket_id, site_id, site_state, ckt_id, circuit, create_date, cleared_dt, closed_dt,
       z.acna, request_type, fld_submitter, assignprofile, customer_ticket_id, 
       max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(substr(f.clli_code,5,2)) keep (dense_rank last order by f.last_modified_date) cllia,
	   max(substr(f2.clli_code,5,2)) keep (dense_rank last order by f2.last_modified_date) clliz,
	   max(f2.clli_code) keep (dense_rank last order by f2.last_modified_date) clli_code,
       max(trim(d.acna)) keep (dense_rank last order by d.last_modified_date) acna1, 
	   max(trim(d.ccna)) keep (dense_rank last order by d.last_modified_date) ccna1,
	   max(trim(d.acna)) keep (dense_rank first order by d.acna) acna2, 
	   max(trim(d.ccna)) keep (dense_rank first order by d.ccna) ccna2
from (
select a.fld_requestid ticket_id, 
       max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
	   a.exchange_carrier_circuit_id ckt_id, 
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT,
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(trim(a.acna)) keep (dense_rank last order by a.fld_modifieddate) acna,    
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
	   max(a.fld_submitter) keep (dense_rank last order by a.fld_modifieddate) fld_submitter,
       max(a.fld_assignmentprofile) keep (dense_rank last order by a.fld_modifieddate) assignprofile,
	   max(c.fld_customertroubleticknum) keep (dense_rank last order by c.dw_load_date_time) customer_ticket_id,
       max(e.location_id) keep (dense_rank last order by e.last_modified_date) location_id,
       max(e.location_id_2) keep (dense_rank last order by e.last_modified_date) location_id_2
from casdw.trouble_ticket_r a,  
	 casdw.circuit e,
	 casdw.work_order_r c
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and a.fld_requestid = c.fld_ticketid (+)
 and (to_char(dte_closeddatetime,'yyyymm') = '202312'    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') = '202312'))   --NEED TO CHANGE THIS EACH MONTH  
group by a.fld_requestid, a.exchange_carrier_circuit_id
) z,
  casdw.design_layout_report d,
  casdw.network_location f,
  casdw.network_location f2
where z.ckt_id = d.ecckt(+)
 and z.location_id = f.location_id(+)
 and z.location_id_2 = f2.location_id(+)  
 group by ticket_id, site_id, site_state, ckt_id, circuit, create_date, cleared_dt, closed_dt,
       z.acna, request_type, fld_submitter, assignprofile, customer_ticket_id
)
)
data, 
 rvv827.carrier_list cl
where clec_id = cl.acna(+)
and (clec_id not in ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',
                     'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ') and clec_id is not null);		 






select customer, sum(electronic) electronic, count(electronic) total --, sum(electronic)/count(electronic)*100 result
from tautilization
where state not in ('WA','OR','ID','MT')
and customer in (
'ATT COMMUNICATIONS',
'ATT MOBILITY',
'LUMEN TECHNOLOGIES',
'EARTHLINK',
'LUMOS',
'SPRINT',
'SPRINT PCS',
'TMOBILE',
'TELEPACIFIC COMMUNICATIONS',
'TW TELECOM',
'US CELLULAR',
'VERIZON BUSINESS',
'VERIZON WIRELESS',
'WINDSTREAM')
--and assignprofile like '%CTF%'
group by customer
order by 1;



--FOR MANUAL DETAIL   
select ticket_id, customer_ticket_id, customer, clec_id, state, ckt_id,
       create_date, 
       case when cleared_dt is not null then cleared_dt
       else closed_dt end cleared_dt, 
       null reported_by, null tn
from tautilization
where fld_submitter not in ('VFOI','$USER$') 
and state not in ('WA','OR','ID','MT')
and customer in (
'ATT COMMUNICATIONS',
'ATT MOBILITY',
'LUMEN TECHNOLOGIES',
'EARTHLINK',
'LUMOS',
'SPRINT',
'SPRINT PCS',
'TMOBILE',
'TELEPACIFIC COMMUNICATIONS',
'TW TELECOM',
'US CELLULAR',
'VERIZON BUSINESS',
'VERIZON WIRELESS',
'WINDSTREAM')
order by 3,1;	   


