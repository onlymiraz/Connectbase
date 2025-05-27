--The Cleared Date and Close Date are stored in GMT.  For EST (winter) - minus 5 hours.  For EDT (Summer) - minus 4 hours  

select region, count(*) Volume, round(sum(ttr)/count(*),2) MTTR, round(((sum(trbl4)/count(*))*100),2) trbllessthan4
from (
select case when st in ('IL','OH') and company = 'ACQUIRED' then 'F9Central'
            when st in ('AZ','ID','NV','WI') and company = 'ACQUIRED' then 'F9National'
			when st in ('CA','OR','WA') and company = 'ACQUIRED' then 'F9West'
			when st in ('OH') then 'F9Central'
			when st in ('WA') then 'F9West'
			when st in ('IL','OH') and substr(circuit,13,4) in ('GTEN','GTEW') then 'F9Central'
			when st in ('AZ','ID','NV','WI') and substr(circuit,13,4) in ('GTEN','GTEW') then 'F9National'
			when st in ('CA','OR','WA') and substr(circuit,13,4) in ('GTEN','GTEW') then 'F9West'
            else 'Other' end region, 
			ttr, docno, trbl4
from (
select distinct docno, trb.icsc, trb.state, netloc, cllist, addstate, priloc, secloc,
       case when trb.state is not null then trb.state
	        when netloc is not null then netloc
            when cllist is not null then cllist
            when addstate is not null then addstate
            when priloc is not null then priloc
            when secloc is not null then secloc
		    when trb.icsc = 'FV01' then 'WV'
			when serv_item_desc like '%/WV%' then 'WV'
            else '??' end st,
       case when acna is not null then acna
            else ccna end CLEC_ID,
	   carrier,
	   customer,  		
       serv_item_desc ckt_id,
	   circuit,  
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
			when substr(circuit,3,2) in ('DR','FD','PE','PL','RT','TC') then 'DS0'
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
	   trb.clli,
	   company,
	   case when ttr <= 4 then 1 else 0 end trbl4
from (
select a.document_number docno, 
       max(b.state) keep (dense_rank last order by b.dw_load_date_time) state,
	   substr(upper(a.office_clli_cd),5,2)  cllist, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
	   max(upper(c.customer_address_state)) keep (dense_rank last order by c.last_modified_date) addstate, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(substr(d.secondary_location,5,2)) keep (dense_rank last order by d.last_modified_date) secloc,
	   max(substr(f.clli_code,5,2)) keep (dense_rank last order by f.last_modified_date) netloc, 
	   a.serv_item_desc, 
	   replace(replace(a.serv_item_desc,' '),'/') circuit,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna, 
	   max(d.issue_nbr) keep (dense_rank last order by d.last_modified_date) issue_nbr,
	   a.Ticket_ID, 
	   a.CREATE_DATE, 
	   max(a.CLEARED_DT-5/24) keep (dense_rank last order by a.last_modified_date) CLEARED_DT, 
       max(a.CLOSE_DT -5/24) keep (dense_rank last order by a.last_modified_date) CLOSED_DT, 
       max(round(a.TOT_DUR/3600,2)) keep (dense_rank last order by a.last_modified_date) Total_Duration, 
	   max(round(a.ttr/3600,2)) keep (dense_rank last order by a.last_modified_date) ttr, 
	   max(a.TRBL_FOUND_ID) keep (dense_rank last order by a.last_modified_date) trbl_found_id,
       max(g.TROUBLE_FOUND_CD) keep (dense_rank last order by a.last_modified_date) trouble_found_cd, 
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
	   max(substr(clli_code,1,6)) keep (dense_rank last order by f.last_modified_date) clli,
	   max(d.interexchange_carrier_name) keep (dense_rank last order by d.last_modified_date) carrier,
	   max(c.customer_premise_name) keep (dense_rank last order by c.last_modified_date) customer
from casdw.trouble_ticket a, 
     casdw.vnet_daily b, 
     casdw.trouble_user_data c, 
     casdw.design_layout_report d,
     casdw.circuit e,
	 casdw.network_location f, 
     casdw.trouble_found_type g
where to_char(a.close_dt-5/24,'yyyymmdd') = '20120410' 
 and a.current_state = 'closed'
 and a.ticket_id = substr(b.cust_tckt_number(+),4,13)
 and a.document_number = c.document_number(+)
 and a.serv_item_desc = d.ecckt(+)
 and a.serv_item_desc = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and e.location_id = f.location_id(+)
 and a.trbl_found_id = g.trbl_found_id(+)
 and a.tt_type_cd <> 'INFORMATION'
 and a.serv_item_type_cd = 'CIRCUIT'
 and resp_org_party_id in ('518336','540992')
 and (e.type <> 'T' or type is null)
group by a.document_number, office_clli_cd, TICKET_ID, CREATE_DATE, serv_item_desc 
) trb, company
where  trb.clli = company.clli_6(+)
and substr(circuit,6,1) <> 'U'   -- removes UNE tickets
and trbl_found_id in ('245','247','284','285','286','287','288','300','242','243','246','254','255','256','257',
                      '258','259','260','289','290','291','241','253','261','263','266','267','268','276','297')				  
)
)
group by region
order by 1

