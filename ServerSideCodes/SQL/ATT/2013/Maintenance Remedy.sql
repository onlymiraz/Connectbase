--The Cleared Date and Close Date are stored in GMT.  For EST (winter) - minus 5 hours.  For EDT (Summer) - minus 4 hours  

drop table ATTMR;


CREATE TABLE ATTMR NOLOGGING NOCACHE AS
select DISTINCT TICKET_ID, STATE, REGION, CLEC_ID, 
       case when clec_id in ('ATX','AAV','SBB','SBZ','SUV','TPM') then 'ATX' else 'MOB' end company,
	   CKT_ID, PRODUCT, CREATE_DATE, CLEARED_DT, CLOSED_DT, TTR, TOTAL_DURATION, REPAIR_CODE, DISP, FOUND,
	   CASE WHEN TTR <= 4 THEN 1 ELSE 0 END TTR4,
	   CASE WHEN TTR <= 8 THEN 1 ELSE 0 END TTR8,
	   initial_ttr, trunc(closed2) closed2
from (
select ticket_id, state, clec_id, cl.customer, ckt_id, product, create_date, cleared_dt, closed_dt,  
       ttr, total_duration, initial_ttr, trbl_found_cd, trbl_found_desc, disp, 
	   CASE WHEN DISP IN ('CO','FAC','CC') THEN 'F'
	        WHEN DISP = 'NTF' THEN 'NF'
			ELSE 'EXC' END FOUND,
	   site_id, repair_code, serv_code,
	   case WHEN STATE IN ('AZ','NV','NM','UT','WI','AL','FL','GA','MS','TN','NC','SC') THEN 'National'
			WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
	        WHEN STATE IN ('IN','KY','AL','FL','GA','MS','TN') THEN 'MIDWEST'
       		WHEN STATE IN ('NY','PA','CT') THEN 'EAST'
			WHEN STATE IN ('IL','MO','OH','WV','MD','VA') THEN 'MID-ATLANTIC'
	  		WHEN STATE IN ('CA','OR','WA','ID','MT') THEN 'WEST'
	  		WHEN STATE IN ('AZ','NM','NV','UT','MN','SC','NC','IA','NE') THEN 'NATIONAL'
			else null end region, closed2
from (
select distinct ticket_id, state, clec_id, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, total_duration, initial_ttr,
	   case when trbl_found_number is not null then trbl_found_number
	        else trbl_found_number2 end trbl_found_cd,
	   case when trbl_found_desc is not null then trbl_found_desc
	        else trbl_found_desc2 end trbl_found_desc,		
	   case when disp3 is not null then disp3
	        when disp is not null then disp
	        else disp2 end disp, site_id,
       repair_code, serv_code, closed2  
from (
select distinct ticket_id, 
       case when icsc = 'RT01' then 'NY'
	        when substr(circuit,1,2) = 'R2' then 'NY'
	        when icsc = 'SN01' then 'CT'
	   		when site_state is not null  
	         and site_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') then site_state
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
			when service_type_code = 'OB' THEN 'OC3'
			when service_type_code = 'OD' THEN 'OC12'
			when service_type_code = 'OF' THEN 'OC48'
			when service_type_code = 'OG' THEN 'OC192'
			when substr(circuit,1,10) like '%OC3%' then 'OC3'
            when substr(circuit,1,10) like '%OC03%' then 'OC3'
            when substr(circuit,1,10) like '%OC12%' then 'OC12'
            when substr(circuit,1,10) like '%OC48%' then 'OC48'
            when substr(circuit,1,10) like '%OC192%' then 'OC192'
			when substr(circuit,3,2) = 'OB' then 'OC3'
            when substr(circuit,3,2) = 'OD' then 'OC12'
            when substr(circuit,3,2) = 'OF' then 'OC48'
            when substr(circuit,3,2) = 'OG' then 'OC192'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when rate_code in ('OC3','OC12','OC48','OC192') then rate_code
			else ' ' end product,
	   case when to_char(Create_Date,'yyyymmdd') > '20151101' then Create_Date-5/24 
	        else Create_Date-4/24 end create_date, 
	   case when to_char(Cleared_Dt,'yyyymmdd') > '20151101' then Cleared_dt-5/24
	        else Cleared_dt-4/24 end Cleared_Dt, 
	   case when to_char(Closed_Dt,'yyyymmdd') > '20151101' then Closed_dt-5/24
	        else Closed_dt-4/24 end Closed_Dt,
       Total_Duration, 
	   TTR, initial_ttr,
	   b.trbl_found_number, b.trbl_found_desc, b.disp, c.trbl_found_number trbl_found_number2, c.trbl_found_desc trbl_found_desc2, c.disp disp2, d.disp disp3,
	   site_id, a.repair_code, serv_code, closed2
from (
select a.fld_requestid ticket_id, 
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
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
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
	   max(round(a.h_fld_totalopentime_secs_/3600,2)) keep (dense_rank last order by a.fld_modifieddate) Total_Duration,
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
	   max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,  
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
	   MAX(E.SERVICE_TYPE_CODE) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) SERV_CODE,
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank first order by a.fld_modifieddate) initial_ttr,
       max(dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) closed2
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile = 'CNOC'
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (e.type <> 'T' or type is null) 
 and (to_char(dte_closeddatetime-5/24,'yyyymm') = '201512' or dte_closeddatetime is null)   --NEED TO CHANGE THIS EACH MONTH 
 --AND d.ISSUE_STATUS = '2'
 and e.status (+) = '6'
group by a.fld_requestid, a.exchange_carrier_circuit_id 
) a, trbl_found_remedy b, repair_code c, trbl_found_remedy d
where a.trbl_found_cd = b.trbl_found_number (+)
and a.repair_code = c.repair_code (+)
and a.repair_code = d.trbl_found_desc (+)
and substr(circuit,6,1) <> 'U'   
and request_type in ('Agent','Alarm','Customer','Maintenance')
and substr(ckt_id,4,2) not in ('VM','EM','IP','IB','FX','YB','YG','UG','UH','RT','PL','LA','LU','XA','LA','LO','LN','LU','FD','US','CS')   
and reqstat = 'Closed' 
and (to_char(cleared_dt,'yyyymm') = '201512' 
   or to_char(closed_dt,'yyyymm') = '201512')
)
where state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN')
and clec_id in ('ATX','AAV','SBB','SBZ','SUV','TPM','AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   		    'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN',
				'BSM','CBL','CCB','CDA','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO',
			    'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL',
				'HGN','HLU','HNC','HTN','IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA',
			    'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB',
				'MWZ','NBC','NWW','OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN',
				'SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD',
				'VRA','WBT','WGL','WLG','WLZ','WVO','WWC')					  	 
)data, rvv827.carrier_list cl
where clec_id = cl.acna(+)
and product in ('DS0','DS1','DS3','OC3','OC12','OC48','OC192','Ethernet')
and disp in ('CO','FAC','CC','NTF')
)					 
order by 4,3,1;




SELECT '1-MTTR-F', COMPANY||' '||PRODUCT, SUM(TTR), COUNT(*) DEN
FROM ATTMR   
WHERE FOUND = 'F'
GROUP BY COMPANY, PRODUCT
--
UNION ALL
--
SELECT '2-MTTR-NF', COMPANY||' '||PRODUCT, SUM(TTR), COUNT(*) DEN
FROM ATTMR   
WHERE FOUND = 'NF'
GROUP BY COMPANY, PRODUCT
--
UNION ALL
--
SELECT '3-TTR-4', COMPANY||' '||PRODUCT, SUM(TTR4), COUNT(*) DEN
FROM ATTMR   
GROUP BY COMPANY, PRODUCT
--
UNION ALL
--
SELECT '4-TTR-8', COMPANY||' '||PRODUCT, SUM(TTR8), COUNT(*) DEN
FROM ATTMR   
WHERE PRODUCT = 'DS1'
GROUP BY COMPANY, PRODUCT
--
UNION ALL
--
SELECT '6-MTTR>4', COMPANY||' '||PRODUCT, SUM(TTR), COUNT(*) DEN
FROM ATTMR   
WHERE TTR > 4
GROUP BY COMPANY, PRODUCT;


select DISTINCT TICKET_ID, STATE, REGION, CLEC_ID,company, CKT_ID,
	   company||' '||PRODUCT, 
       CREATE_DATE, CLEARED_DT, CLOSED_DT, TTR, TOTAL_DURATION, REPAIR_CODE, DISP, FOUND,
	   TTR4, TTR8, initial_ttr
from attmr;




