
select ticket_id, state, 
       clec_id, customer carrier, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, repair_code, disp, clli_code, request_type, location_name, assignprof
from (
select distinct ticket_id, state, clec_id, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, total_duration, repair_code, disp, clli_code,
       wh.area_name zclliarea, zclli, wh2.area_name zexcharea, zexch, wh3.area_name aclliarea, aclli,
	   reqstat, request_type, location_name, cl.customer, assignprof
from (
select distinct ticket_id, 
       case when icsc = 'RT01' then 'NY'
	        when substr(circuit,1,2) in ('R2','T-','T1','T3') then 'NY'
	   		when clliz is not null 
			 and clliz in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then clliz
			when site_state is not null and site_id <> 'NON INVENTORIED CIRCUIT'
	         and site_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then site_state 
	        when cllia is not null 
			 and cllia in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then cllia
            when priloc is not null 
			 and priloc in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then priloc
		    when icsc = 'FV01' then 'WV'
			when ckt_id like '%/WV%' then 'WV'
		    when substr(circuit,1,2) in ('50','54','56') then 'WV'
            else null end state,
       case when acna is not null then acna
	        when acna1 is not null then acna1
	        when ccna1 is not null then ccna1
			when acna2 is not null then acna2
            else ccna2 end CLEC_ID,		
       ckt_id,  
	   case when service_type_code = 'HC' then 'DS1'
			when service_type_code = 'HF' then 'DS3'
	   	 	when substr(circuit,4,5) like '%T1%' then 'DS1'
			when substr(circuit,4,5) like '%T3%' then 'DS3'
			when substr(circuit,1,4) like '%HC%' then 'DS1'
			when substr(circuit,1,4) like '%HF%' then 'DS3'
			when substr(circuit,1,2) = 'R2' then 'Ethernet'
            when substr(circuit,3,2) in ('L1','L2') then 'Ethernet'
            when substr(circuit,4,2) in ('IP') then 'DS1'
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'
			when substr(circuit,3,1) in ('X','L') then 'DS0'
			when substr(service_type_code,1,2) = 'OC' then 'OCN'
			when substr(circuit,1,8) like '%OC%' then 'OCN'
			when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
            when substr(service_type_code,1,2) = 'SX' then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
			else ' ' end product,
	   create_date, 
	   case when Cleared_Dt is not null then Cleared_dt
            else Closed_dt end Cleared_Dt, 
	   case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,
       Total_Duration, 
	   TTR,
	   a.repair_code, b.disp,
	   clli_code, aclli, aexch, zclli, zexch,
	   reqstat, request_type, 
	   replace(replace(location_name, chr(13)),chr(10)) location_name, assignprof
from (
select a.fld_requestid ticket_id, 
       max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(substr(f.clli_code,5,2)) keep (dense_rank last order by f.last_modified_date) cllia,
	   max(substr(f2.clli_code,5,2)) keep (dense_rank last order by f2.last_modified_date) clliz,
	   max(f2.clli_code) keep (dense_rank last order by f2.last_modified_date) clli_code,
	   a.exchange_carrier_circuit_id ckt_id, 
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
	   max(trim(a.acna)) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(trim(d.acna)) keep (dense_rank last order by d.last_modified_date) acna1, 
	   max(trim(d.ccna)) keep (dense_rank last order by d.last_modified_date) ccna1,
	   max(trim(d.acna)) keep (dense_rank first order by d.acna) acna2, 
	   max(trim(d.ccna)) keep (dense_rank first order by d.ccna) ccna2,
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
	   max(round(a.h_fld_totalopentime_secs_/3600,2)) keep (dense_rank last order by a.fld_modifieddate) Total_Duration,
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
	   max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,  
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
	   max(substr(f.clli_code,1,6)) keep (dense_rank last order by f.last_modified_date) aclli,
	   max(substr(f.exchange_area_clli,1,6)) keep (dense_rank last order by f.last_modified_date) aexch,
	   max(substr(f2.clli_code,1,6)) keep (dense_rank last order by f2.last_modified_date) zclli,
	   max(substr(f2.exchange_area_clli,1,6)) keep (dense_rank last order by f2.last_modified_date) zexch,
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
	   max(a.fld_alocationaccessname2) location_name,
       max(a.fld_assignmentprofile) keep (dense_rank last order by a.fld_modifieddate) assignprof
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e,
	 casdw.network_location f,
	 casdw.network_location f2
where a.fld_troublereportstate = 'closed'
 --and a.fld_assignmentprofile in ('CNOC','Commercial-CTF','FTW TSC','CTF TSC','Frontier Premier')
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and e.location_id = f.location_id(+)
 and e.location_id_2 = f2.location_id(+)
 and (to_char(dte_closeddatetime,'yyyymm') in ('201910')    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') in ('201910')))   --NEED TO CHANGE THIS EACH MONTH
 and (fld_alocationaccessname2 like '%WEGMAN%'
    or fld_alocationaccessname2 like '%Wegman%'
    or fld_alocationaccessname2 like '%wegman%') 	
group by a.fld_requestid, a.exchange_carrier_circuit_id
) a, trbl_found_remedy b
where a.repair_code = b.trbl_found_desc (+)
and reqstat = 'Closed' 
)data, 
 rvv827.carrier_list cl,
 rvv827.west_hierarchy wh,
 rvv827.west_hierarchy wh2,
 rvv827.west_hierarchy wh3
where clec_id = cl.acna(+)
and zclli = wh.clli6 (+)
and zexch = wh2.clli6 (+)
and aclli = wh3.clli6 (+) 
)				 
order by 4,3,1;