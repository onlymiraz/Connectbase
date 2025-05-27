select docno, state, clec_id, carrier, customer, ckt_id, icsc, product, ticket_id, create_date, cleared_dt, closed_dt, ttr, trbl_id, trbl_desc
from (
select distinct docno, 
       case when clliz is not null and clliz in ('IL') then clliz
	        when cllia is not null and cllia in ('IL') then cllia 
	        when state is not null and state in ('IL') then state
	        when cllist is not null and cllist in ('IL') then cllist
            when addstate is not null and addstate in ('IL') then addstate
            else null end state,
       case when acna is not null then acna
            else ccna end CLEC_ID,
	   carrier, 		
       serv_item_desc ckt_id, ICSC,   
	   case when service_type_code = 'HC' then 'DS1'
			when service_type_code = 'HF' then 'DS3'
	   	 	when substr(circuit,4,5) like '%T1%' then 'DS1'
			when substr(circuit,4,5) like '%T3%' then 'DS3'
			when substr(circuit,1,4) like '%HC%' then 'DS1'
			when substr(circuit,1,4) like '%HF%' then 'DS3'
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'
			when substr(circuit,3,1) in ('X','L') then 'DS0'
			when substr(service_type_code,1,2) = 'OC' then 'OCN'
			when substr(circuit,1,8) like '%OC%' then 'OCN'
			when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
			when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
			else ' ' end product,
	   Ticket_ID,  
	   Create_Date, 
	   case when to_char(Cleared_Dt,'yyyymmdd') > '20140309' then Cleared_dt-4/24
	        else Cleared_dt-5/24 end Cleared_Dt, 
	   case when to_char(Closed_Dt,'yyyymmdd') > '20140309' then Closed_dt-4/24
	        else Closed_dt-5/24 end Closed_Dt, 
	   TTR,
	   Trbl_Found_ID trbl_id, 
	   Trouble_Found_CD trbl_desc
from (
select a.document_number docno, 
       max(b.state) keep (dense_rank last order by b.dw_load_date_time) state, 
	   substr(upper(a.office_clli_cd),5,2)  cllist, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
	   max(upper(c.customer_address_state)) keep (dense_rank last order by c.last_modified_date) addstate, 
	   max(substr(f.clli_code,5,2)) keep (dense_rank last order by f.last_modified_date) cllia,
	   max(substr(f2.clli_code,5,2)) keep (dense_rank last order by f2.last_modified_date) clliz,
	   a.serv_item_desc,
	   replace(replace(a.serv_item_desc,' '),'/') circuit, 
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna,
	   max(a.tt_type_cd) keep (dense_rank last order by a.last_modified_date) tt_type_cd,
	   a.Ticket_ID, 
	   a.CREATE_DATE, 
	   max(a.CLEARED_DT) keep (dense_rank last order by a.last_modified_date) CLEARED_DT, 
       max(a.CLOSE_DT) keep (dense_rank last order by a.last_modified_date) CLOSED_DT,  
	   max(round(a.ttr/3600,2)) keep (dense_rank last order by a.last_modified_date) ttr, 
	   max(a.TRBL_FOUND_ID) keep (dense_rank last order by a.last_modified_date) trbl_found_id,
       max(g.TROUBLE_FOUND_CD) keep (dense_rank last order by a.last_modified_date) TROUBLE_FOUND_CD, 
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
	   max(d.interexchange_carrier_name) keep (dense_rank last order by d.last_modified_date) carrier
from casdw.trouble_ticket a, 
     casdw.vnet_daily b, 
     casdw.trouble_user_data c, 
     casdw.design_layout_report d,
     casdw.circuit e,
	 casdw.network_location f,
	 casdw.network_location f2, 
     casdw.trouble_found_type g
where to_char(a.close_dt-4/24,'yyyymm') = '201401' 
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
 and e.status (+) = '6'
 and substr(a.serv_item_desc,6,2) = 'FS'
group by a.document_number, office_clli_cd, a.serv_item_desc, TICKET_ID, CREATE_DATE	
)
where tt_type_cd = 'CUSTOMER'
and trbl_found_id in ('245','247','284','285','286','287','288','300','242','243','246','254','255','256','257',
                      '258','259','260','289','290','291','241','253','261','263','266','267','268','276','297')
)data, rvv827.carrier_list cl
where clec_id = cl.acna(+) 
and state = 'IL'	
and clec_id not in ('ZZZ','FLR')				  
order by 11


