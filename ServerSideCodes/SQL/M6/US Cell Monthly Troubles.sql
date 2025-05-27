--The Cleared Date and Close Date are stored in GMT.  For EST (winter) - minus 5 hours.  For EDT (Summer) - minus 4 hours  


select ticket_id, 'US CELLULAR' customer, ckt_id, product service, state,
       clec_id acna, create_date, cleared_dt, closed_dt, 
       repair_code, disp, ttr, null initiator 
from (
select ticket_id, state, clec_id, ckt_id, product, create_date, cleared_dt, closed_dt,  
       ttr, total_duration, trbl_found_cd, trbl_found_desc, disp, clli_code,
		reqstat, trblstat, repair_code, causecode, faultloc, request_type ticket_type	
from (
select distinct ticket_id, state, clec_id, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, total_duration, 
	   case when trbl_found_number is not null then trbl_found_number
	        else trbl_found_number2 end trbl_found_cd,
	   case when trbl_found_desc is not null then trbl_found_desc
	        else trbl_found_desc2 end trbl_found_desc,		
	   case when disp3 is not null then disp3
	        when disp is not null then disp
	        else disp2 end disp, clli_code,
       wh.area_name zclliarea, zclli, wh2.area_name zexcharea, zexch, wh3.area_name aclliarea, aclli,
	   reqstat, trblstat, repair_code, causecode, faultloc, request_type  
from (
select distinct ticket_id, 
       case when icsc = 'RT01' then 'NY'
	        when substr(circuit,1,2) = 'R2' then 'NY'
	   		when clliz is not null 
			 and clliz in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then clliz
			when site_state is not null 
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
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'
			when substr(circuit,3,1) in ('X','L') then 'DS0'
			when substr(service_type_code,1,2) = 'OC' then 'OCN'
			when substr(circuit,1,8) like '%OC%' then 'OCN'
			when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
			else ' ' end product,
	   case when to_char(Create_Date,'yyyymmdd') > '20150307' then Create_Date-4/24 
	        else Create_Date-5/24 end create_date, 
	   case when to_char(Cleared_Dt,'yyyymmdd') > '20150307' then Cleared_dt-4/24
	        else Cleared_dt-5/24 end Cleared_Dt, 
	   case when to_char(Closed_Dt,'yyyymmdd') > '20150307' then Closed_dt-4/24
	        else Closed_dt-5/24 end Closed_Dt,
       Total_Duration, 
	   TTR,
	   b.trbl_found_number, b.trbl_found_desc, b.disp, c.trbl_found_number trbl_found_number2, c.trbl_found_desc trbl_found_desc2, c.disp disp2, d.disp disp3,
	   clli_code, aclli, aexch, zclli, zexch,
	   reqstat, trblstat, a.repair_code, causecode, faultloc, request_type
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
	   max(d.acna) keep (dense_rank first order by d.acna) acna2, 
	   max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,
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
	   max(substr(f.clli_code,1,6)) keep (dense_rank last order by f.last_modified_date) aclli,
	   max(substr(f.exchange_area_clli,1,6)) keep (dense_rank last order by f.last_modified_date) aexch,
	   max(substr(f2.clli_code,1,6)) keep (dense_rank last order by f2.last_modified_date) zclli,
	   max(substr(f2.exchange_area_clli,1,6)) keep (dense_rank last order by f2.last_modified_date) zexch,
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
	   max(a.fld_troublereportstate) keep (dense_rank last order by a.fld_modifieddate) trblstat,
	   max(a.fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) causecode,
	   max(a.fld_complete_faultlocation) keep (dense_rank last order by a.fld_modifieddate) faultloc
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
 and to_char(a.fld_event_end_time,'yyyymm') = '201501'    --NEED TO CHANGE THIS EACH MONTH 
group by a.fld_requestid, a.exchange_carrier_circuit_id 
) a, trbl_found_remedy b, repair_code c, trbl_found_remedy d
where a.trbl_found_cd = b.trbl_found_number (+)
and a.repair_code = c.repair_code (+)
and a.repair_code = d.trbl_found_desc (+)
and substr(circuit,6,1) <> 'U' 
and request_type in ('Agent','Alarm','Customer','Maintenance')  
and substr(ckt_id,4,2) not in ('VM','EM','IP','IB','FX','YB','YG','UG','UH','RT','PL','LA','LU','XA','LA','LO','LN','LU','FD','US','CS')
and to_char(closed_dt,'yyyymm') = '201501'    --NEED TO CHANGE THIS EACH MONTH 
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
and data.state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN')
and data.product in ('DS0','DS1','DS3','OCN','Ethernet')
and clec_id in ('UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','USC','WCT')		 
)
)					 
order by 4,3,1;



---From OS3 view to capture the initator  
select fld_requestid, fld_managercontactpersonname, fld_managercontactpersonphone
from os3.os3_op_request
where fld_requestid in (
'OP-000000563031'
)
;

---From CNEPRD OS3 view to capture the initator
select fld_requestid, fld_managercontactpersonname, fld_managercontactpersonphone
from whsl_adv_hist.os3_op_request
where fld_requestid in (
