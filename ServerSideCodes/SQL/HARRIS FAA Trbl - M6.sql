--The Cleared Date and Close Date are stored in GMT.  For EST (winter) - minus 5 hours.  For EDT (Summer) - minus 4 hours  

select ticket_id, st state, ckt_id, to_char(closed_dt,'mm/yyyy') month, create_date, cleared_dt, prod, trouble_found_cd, ttr,
       case when TTR <= 3 then '0 to 3'
	      when TTR between 3.01 and 4 then '3 to 4'
		  when TTR between 4.01 and 5 then '4 to 5'
		  when TTR between 5.01 and 7 then '5 to 7'
		  when TTR between 7.01 and 9 then '7 to 9'
		  else '9+' end mttr_group,
	   customer, cleared_comment  
from (
select distinct docno,
       case when state is not null then state
	        when netlocz is not null then netlocz
			when netloca is not null then netloca
            when cllist is not null then cllist
            when addstate is not null then addstate
            when priloc is not null then priloc
            when secloc is not null then secloc
		    when icsc = 'FV01' then 'WV'
			when serv_item_desc like '%/WV%' then 'WV'
		    when substr(circuit,1,2) = '31' then 'IN'
		    when substr(circuit,1,2) = '61' then 'NC'
		    when substr(circuit,1,2) = '62' then 'SC'
		    when substr(circuit,1,2) in ('50','54','56') then 'WV'
            else ' ' end st,
       case when acna is not null then acna
            else ccna end CLEC_ID,
	   carrier,
	   customer,  		
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
			when substr(circuit,1,6) like '%OC%' then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,2) in ('DR','FD','PE','PL','RT','TC','UC') then 'DS0'
			when substr(circuit,3,2) in ('DH','FL','IP','QG','YB','YG') then 'DS1'
			when rate_code is not null then rate_code
			else ' ' end prod,
	   Ticket_ID,  
	   Create_Date, 
	   Cleared_Dt, 
	   Closed_Dt,
       Total_Duration Tot_Dur, 
	   TTR,
	   Trbl_Found_ID, 
	   Trouble_Found_CD,
	   replace(replace(CLEARED_COMMENT,chr(10),''),chr(13),'') cleared_comment,
	   state, netloca, netlocz, cllist, addstate, priloc, secloc	
from (
select a.document_number docno, 
       state, 
	   substr(upper(a.office_clli_cd),5,2)  cllist, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
	   max(upper(c.customer_address_state)) keep (dense_rank last order by c.last_modified_date) addstate, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(substr(d.secondary_location,5,2)) keep (dense_rank last order by d.last_modified_date) secloc,
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) netloca,
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl2.last_modified_date) netlocz,
	   a.serv_item_desc, 
	   replace(replace(a.serv_item_desc,' '),'/') circuit,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna, 
	   max(d.issue_nbr) keep (dense_rank last order by d.last_modified_date) issue_nbr,
	   a.Ticket_ID, 
	   a.CREATE_DATE, 
	   max(a.CLEARED_DT-4/24) keep (dense_rank last order by a.last_modified_date) CLEARED_DT, 
       max(a.CLOSE_DT -4/24) keep (dense_rank last order by a.last_modified_date) CLOSED_DT,  
       max(round(a.TOT_DUR/3600,2)) keep (dense_rank last order by a.last_modified_date) Total_Duration, 
	   max(round(a.ttr/3600,2)) keep (dense_rank last order by a.last_modified_date) ttr, 
	   max(a.TRBL_FOUND_ID) keep (dense_rank last order by a.last_modified_date) trbl_found_id,
       max(g.TROUBLE_FOUND_CD) keep (dense_rank last order by a.last_modified_date) TROUBLE_FOUND_CD, 
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   e.service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
	   max(d.interexchange_carrier_name) keep (dense_rank last order by d.last_modified_date) carrier,
	   max(c.customer_premise_name) keep (dense_rank last order by c.last_modified_date) customer,
	   max(a.cleared_comment) keep (dense_rank last order by a.last_modified_date)cleared_comment 
from casdw.trouble_ticket a, 
     casdw.vnet_daily b, 
     casdw.trouble_user_data c, 
     casdw.design_layout_report d,
     casdw.circuit e,
	 casdw.network_location nl1,
	 casdw.network_location nl2, 
     casdw.trouble_found_type g
where to_char(a.close_dt-4/24,'yyyymm') = '201407' 
 and a.current_state = 'closed'
 and a.ticket_id = substr(b.cust_tckt_number(+),4,13)
 and a.document_number = c.document_number(+)
 and a.serv_item_desc = d.ecckt(+)
 and a.serv_item_desc = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and e.location_id = nl1.location_id(+)
 and e.location_id_2 = nl2.location_id(+)
 and a.trbl_found_id = g.trbl_found_id(+)
 and a.tt_type_cd = 'CUSTOMER'
 and a.serv_item_type_cd = 'CIRCUIT'
 and resp_org_party_id in ('518336','540992','541368')
 and (e.type <> 'T' or type is null)
 and (customer_premise_name like '%FAA%'
or customer_premise_name like '%Faa%'
or customer_premise_name like '%faa%'
or customer_premise_name like '%Harris%'
or customer_premise_name like '%HARRIS%'
or customer_premise_name like '%harris%')
and customer_premise_name not like '%arrison%'
and customer_premise_name not like '%ARRISON%'
and customer_premise_name not like '%arrisville%'
and customer_premise_name not like '%ank%'
and customer_premise_name not like '%FINANCIAL%'
group by a.document_number, state, office_clli_cd, TICKET_ID, CREATE_DATE,   
         serv_item_desc, service_type_code	
)
where substr(circuit,6,1) <> 'U'   -- removes UNE tickets
)
order by 1
