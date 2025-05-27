--The Cleared Date and Close Date are stored in GMT.  For EST (winter) - minus 5 hours.  For EDT (Summer) - minus 4 hours  



select docno, state, region, clec_id, carrier, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, tot_dur, trbl_id, 'FIRST' ord
from (
select docno, data.state, 
       case when state in ('NY','PA') then 'Northeast'
	        when state in ('WV','MD','VA','SC','NC') then 'Southeast'
			when state in ('IN','MI','KY') then 'Midwest'
			when state in ('IL','MN','OH') then 'Central'
			when state in ('CA','OR','WA') then 'West'
			when state in ('AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then 'National'
			else null end region,
       clec_id, cl.customer carrier, premise_name, ckt_id, product, ticket_id, create_date, cleared_dt, closed_dt, 
       tot_dur, ttr, trbl_id, trbl_desc, clli_code
from (
select distinct docno, 
       case when clliz is not null 
	         and clliz in ('NY','PA','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then clliz
	        when cllia is not null 
			 and clliz in ('NY','PA','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then cllia 
	        when state is not null 
			 and state in ('NY','PA','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then state
	        when cllist is not null 
			 and cllist in ('NY','PA','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then cllist
            when addstate is not null 
			 and addstate in ('NY','PA','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then addstate
            when priloc is not null 
			 and priloc in ('NY','PA','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then priloc
		    when icsc = 'FV01' then 'WV'
			when serv_item_desc like '%/WV%' then 'WV'
		    when substr(circuit,1,2) in ('50','54','56') then 'WV'
            else null end state,
       case when acna is not null then acna
            else ccna end CLEC_ID,
	   carrier,
	   premise_name,  		
       serv_item_desc ckt_id,  
	   case when service_type_code = 'HC' then 'DS1'
			when service_type_code = 'HF' then 'DS3'
			when substr(circuit,4,4) like '%T1%' then 'DS1'
			when substr(circuit,4,4) like '%T3%' then 'DS3'
			when substr(circuit,1,4) like '%HC%' then 'DS1'
			when substr(circuit,1,4) like '%HF%' then 'DS3'
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'
			when substr(circuit,3,1) in ('X','L') then 'DS0'
			when substr(service_type_code,1,2) = 'OC' then 'OCN'
			when substr(circuit,1,8) like '%OC%' then 'OCN'
			when substr(circuit,4,2) in ('OB','OD','OF','OG') then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,2) in ('DR','FD','PE','PL','RT','TC') then 'DS0'
			when substr(circuit,3,2) in ('DH','FL','IP','QG','YB','YG') then 'DS1'
			when rate_code is not null then rate_code
			else ' ' end product,
	   Ticket_ID,  
	   Create_Date, 
	   Cleared_Dt, 
	   Closed_Dt,
       Total_Duration Tot_Dur, 
	   TTR,
	   Trbl_Found_ID trbl_id, 
	   Trouble_Found_CD trbl_desc,
	   clli_code
from (
select a.document_number docno, 
       max(b.state) keep (dense_rank last order by b.dw_load_date_time) state, 
	   substr(upper(a.office_clli_cd),5,2)  cllist, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
	   max(upper(c.customer_address_state)) keep (dense_rank last order by c.last_modified_date) addstate, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(substr(f.clli_code,5,2)) keep (dense_rank last order by f.last_modified_date) cllia,
	   max(substr(f2.clli_code,5,2)) keep (dense_rank last order by f2.last_modified_date) clliz,
	   max(f.clli_code) keep (dense_rank last order by f.last_modified_date) clli_code,
	   a.serv_item_desc, 
	   replace(replace(a.serv_item_desc,' '),'/') circuit,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna, 
	   max(d.issue_nbr) keep (dense_rank last order by d.last_modified_date) issue_nbr,
	   max(a.tt_type_cd) keep (dense_rank first order by a.last_modified_date) tt_type_cd,
	   a.Ticket_ID, 
	   a.CREATE_DATE, 
	   max(a.CLEARED_DT-4/24) keep (dense_rank first order by a.last_modified_date) CLEARED_DT, 
       max(a.CLOSE_DT -4/24) keep (dense_rank first order by a.last_modified_date) CLOSED_DT,  
       max(round(a.TOT_DUR/3600,2)) keep (dense_rank first order by a.last_modified_date) Total_Duration, 
	   max(round(a.ttr/3600,2)) keep (dense_rank first order by a.last_modified_date) ttr, 
	   max(a.TRBL_FOUND_ID) keep (dense_rank first order by a.last_modified_date) trbl_found_id,
       max(g.TROUBLE_FOUND_CD) keep (dense_rank first order by a.last_modified_date) TROUBLE_FOUND_CD, 
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
	   max(d.interexchange_carrier_name) keep (dense_rank last order by d.last_modified_date) carrier,
	   max(c.customer_premise_name) keep (dense_rank last order by c.last_modified_date) premise_name
from casdw.trouble_ticket a, 
     casdw.vnet_daily b, 
     casdw.trouble_user_data c, 
     casdw.design_layout_report d,
     casdw.circuit e,
	 casdw.network_location f,
	 casdw.network_location f2, 
     casdw.trouble_found_type g
where to_char(a.close_dt-4/24,'yyyymm') = '201212' 
 and a.current_state = 'closed'
 and a.ticket_id = substr(b.cust_tckt_number(+),4,13)
 and a.document_number = c.document_number(+)
 and a.serv_item_desc = d.ecckt(+)
 and a.serv_item_desc = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and e.location_id = f.location_id(+)
 and e.location_id_2 = f2.location_id(+)
 and a.trbl_found_id = g.trbl_found_id(+)
 and a.serv_item_type_cd = 'CIRCUIT'
 and resp_org_party_id in ('518336','540992','541368')
 and (e.type <> 'T' or type is null)  
group by a.document_number, office_clli_cd, a.serv_item_desc, TICKET_ID, CREATE_DATE	
)
where substr(circuit,6,1) <> 'U'   -- removes UNE tickets  
and tt_type_cd <> 'INFORMATION'
and trbl_found_id in ('245','247','284','285','286','287','288','300','242','243','246','254','255','256','257',
                      '258','259','260','289','290','291','241','253','261','263','266','267','268','276','297')
)data, rvv827.carrier_list cl
where clec_id = cl.acna(+)
and (clec_id <> 'ZTK' or clec_id is null)) 
