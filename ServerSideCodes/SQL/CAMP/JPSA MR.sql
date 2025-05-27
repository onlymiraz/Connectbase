--Aggregate  
select state, 'MR-2-01-'||mr2prod prod, count(*) num, null denom
from jpsamr
group by state, mr2prod
UNION ALL
select state, 'MR-3-01-'||mr3prod prod, sum(met) num, count(*) denom
from jpsamr
group by state, mr3prod
UNION ALL
select state, 'MR-4-01-'||mr3prod prod, sum(TTR) num, count(*) denom
from jpsamr
group by state, mr3prod 
UNION ALL
select state, 'MR-5-01-'||mr2prod prod, null num, count(*) denom
from jpsamr
group by state, mr2prod
order by 1,2

--CLEC Specific  
select state, clec_id, 'MR-2-01-'||mr2prod prod, count(*) num, null denom
from jpsamr
group by state, clec_id, mr2prod
UNION ALL
select state, clec_id, 'MR-3-01-'||mr3prod prod, sum(met) num, count(*) denom
from jpsamr
group by state, clec_id, mr3prod
UNION ALL
select state, clec_id, 'MR-4-01-'||mr3prod prod, sum(TTR) num, count(*) denom
from jpsamr
group by state, clec_id, mr3prod 
UNION ALL
select state, clec_id, 'MR-5-01-'||mr2prod prod, null num, count(*) denom
from jpsamr
group by state, clec_id, mr2prod
order by 1,2,3

select * from jpsamr
order by 2,15,3


drop table jpsamr;

create table jpsamr nologging nocache as
select ticket_id, state, 					
       clec_id, ckt_id, product, create_date, cleared_dt, closed_dt, 					
       ttr, met, repair_code, disp, clli_code, vnet, mr2prod, mr3prod	
--	   state, clec_id, mr2prod, mr3prod, count(*)				
from (					
select ticket_id, state, clec_id, carrier, ckt_id, product, create_date, cleared_dt, closed_dt,  					
       ttr, 
	   case when TTR > 24 then 1 else 0 end met,
	   total_duration, trbl_found_cd, trbl_found_desc, disp, clli_code,					
		reqstat, trblstat, repair_code, causecode, faultloc, vnet, mr2prod, mr3prod			
from (					
select distinct ticket_id, state, clec_id, carrier, ckt_id, product, create_date, cleared_dt, closed_dt, 					
       ttr, total_duration, 					
	   case when trbl_found_number is not null then trbl_found_number				
	        else trbl_found_number2 end trbl_found_cd,				
	   case when trbl_found_desc is not null then trbl_found_desc				
	        else trbl_found_desc2 end trbl_found_desc,				
	   case when disp3 is not null then disp3				
	        when disp is not null then disp				
	        else disp2 end disp, clli_code,				
	   reqstat, trblstat, repair_code, causecode, faultloc, vnet,
	   case when substr(ckt_id,4,4) in ('TYNU','TYSU') then '3221'
	        when substr(ckt_id,4,4) in ('DHSU','AQSU','FZDU','ASDU','HISU') then '3223'
			when substr(ckt_id,4,4) in ('HCFU') then '3563'
			when substr(ckt_id,4,4) in ('HFFU') then '3561'
			else 'UNK' end MR2prod,
	   case when substr(ckt_id,4,4) in ('TYNU','TYSU') and vnet is not null then '3235'
	        when substr(ckt_id,4,4) in ('TYNU','TYSU') and vnet is null then '3236'
			when substr(ckt_id,4,4) in ('DHSU','AQSU','FZDU','ASDU','HISU') and vnet is not null then '3241'
			when substr(ckt_id,4,4) in ('DHSU','AQSU','FZDU','ASDU','HISU') and vnet is null then '3242'
			when substr(ckt_id,4,4) in ('HCFU') and vnet is not null then '3585'
			when substr(ckt_id,4,4) in ('HCFU') and vnet is null then '3586'
			when substr(ckt_id,4,4) in ('HFFU') and vnet is not null then '3587'
			when substr(ckt_id,4,4) in ('HFFU') and vnet is null then '3588'
			else 'UNK' end MR3prod
from (					
select distinct ticket_id, 					
       case when site_state is not null 					
	         and site_state in ('OR','WA') then site_state				
	        when clliz is not null 				
			 and clliz in ('OR','WA') then clliz 		
	        when cllia is not null 				
			 and cllia in ('OR','WA') then cllia		
            when priloc is not null 					
			 and priloc in ('OR','WA') then priloc		
            else null end state,					
       case when acna is not null then acna					
	        when acna1 is not null then acna1				
	        when ccna1 is not null then ccna1				
			when acna2 is not null then acna2		
            else ccna2 end CLEC_ID,					
	   carrier, 				
       ckt_id,  					
	   case when service_type_code = 'HC' then 'DS1'
	   		when service_type_code = 'DH' then 'DS1'
			when service_type_code = 'AS' then 'DS1'
			when service_type_code = 'AQ' then 'DS1'
			when service_type_code = 'FZ' then 'DS1'
			when service_type_code = 'TY' then 'DS0'
			when service_type_code = 'HF' then 'DS3'
			when service_type_code = 'HI' then 'DS3'		
	   	 	when substr(circuit,4,5) like '%T1%' then 'DS1'		
			when substr(circuit,4,5) like '%T3%' then 'DS3'		
			when substr(circuit,1,4) like '%HC%' then 'DS1'		
			when substr(circuit,1,4) like '%HF%' then 'DS3'		
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'		
			when substr(circuit,3,1) in ('X','L') then 'DS0'		
			when substr(service_type_code,1,2) = 'OC' then 'OCN'		
			when substr(circuit,1,8) like '%OC%' then 'OCN'		
			when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'		
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'		
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'		
			when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'		
			else ' ' end product,		
	   case when to_char(Create_Date,'yyyymmdd') > '20141101' then Create_Date-5/24 				
	        else Create_Date-4/24 end create_date, 				
	   case when to_char(Cleared_Dt,'yyyymmdd') > '20141101' then Cleared_dt-5/24				
	        else Cleared_dt-4/24 end Cleared_Dt, 				
	   case when to_char(Closed_Dt,'yyyymmdd') > '20141101' then Closed_dt-5/24				
	        else Closed_dt-4/24 end Closed_Dt,				
       Total_Duration, 					
	   TTR,				
	   b.trbl_found_number, b.trbl_found_desc, b.disp, c.trbl_found_number trbl_found_number2, c.trbl_found_desc trbl_found_desc2, c.disp disp2, d.disp disp3,				
	   clli_code, aclli, aexch, zclli, zexch,				
	   reqstat, trblstat, a.repair_code, causecode, faultloc, vnet				
from (				
select a.fld_requestid ticket_id, 					
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 					
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 				
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 					
	   max(substr(f.clli_code,5,2)) keep (dense_rank last order by f.last_modified_date) cllia,				
	   max(substr(f2.clli_code,5,2)) keep (dense_rank last order by f2.last_modified_date) clliz,				
	   max(f2.clli_code) keep (dense_rank last order by f2.last_modified_date) clli_code,				
	   a.exchange_carrier_circuit_id ckt_id, 				
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,				
	   max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna,				
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 					
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,				
	   max(d.acna) keep (dense_rank first order by d.last_modified_date) acna2, 				
	   max(d.ccna) keep (dense_rank first order by d.last_modified_date) ccna2,				
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 				
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,				
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 				
       max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,					
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,				
	   max(round(a.h_fld_totalopentime_secs_/3600,2)) keep (dense_rank last order by a.fld_modifieddate) Total_Duration,				
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,				
	   max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,  				
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,					
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 				
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,				
	   max(d.interexchange_carrier_name) keep (dense_rank last order by d.last_modified_date) carrier,				
	   max(substr(f.clli_code,1,6)) keep (dense_rank last order by f.last_modified_date) aclli,				
	   max(substr(f.exchange_area_clli,1,6)) keep (dense_rank last order by f.last_modified_date) aexch,				
	   max(substr(f2.clli_code,1,6)) keep (dense_rank last order by f2.last_modified_date) zclli,				
	   max(substr(f2.exchange_area_clli,1,6)) keep (dense_rank last order by f2.last_modified_date) zexch,				
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,				
	   max(a.fld_troublereportstate) keep (dense_rank last order by a.fld_modifieddate) trblstat,				
	   max(a.fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) causecode,				
	   max(a.fld_complete_faultlocation) keep (dense_rank last order by a.fld_modifieddate) faultloc,				
	   max(a.fld_vnet_id) keep (dense_rank last order by a.fld_modifieddate) vnet				
from casdw.trouble_ticket_r a,  					
     casdw.design_layout_report d,					
     casdw.circuit e,					
	 casdw.network_location f,				
	 casdw.network_location f2				
where a.fld_troublereportstate = 'closed'					
 and a.fld_assignmentprofile = 'CNOC'					
 and a.exchange_carrier_circuit_id = d.ecckt(+)					
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)					
 and e.location_id = f.location_id(+)					
 and e.location_id_2 = f2.location_id(+)					
 and (e.type <> 'T' or type is null) 					
 and e.status (+) = '6'	
 and to_char(a.fld_event_end_time,'yyyymm') = '201410'				
group by a.fld_requestid, a.exchange_carrier_circuit_id 				
) a, trbl_found_remedy b, repair_code c, trbl_found_remedy d					
where a.trbl_found_cd = b.trbl_found_number (+)					
and a.repair_code = c.repair_code (+)					
and a.repair_code = d.trbl_found_desc (+)					
and substr(circuit,6,1) = 'U'   					
and request_type in ('Agent','Alarm','Customer','Maintenance')					
and substr(ckt_id,4,2) not in ('VM','EM','IP','IB','FX','YB','YG','UG','UH','RT','PL','LA','LU','XA','LA','LO','LN','LU','FD','US','CS')					
and to_char(closed_dt,'yyyymm') = '201410'    --NEED TO CHANGE THIS EACH MONTH 					
and reqstat = 'Closed' 					
)data, 					
 rvv827.carrier_list cl					
where clec_id = cl.acna(+)					
and data.state in ('OR','WA')					
and clec_id not in ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',					
                     'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ')		 			
)					
where disp in ('CO','FAC','CC','NTF')					 
)	
--group by state, clec_id, mr2prod, mr3prod				
order by 1,2,3,4					
