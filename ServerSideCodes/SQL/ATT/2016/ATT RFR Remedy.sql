--The Cleared Date and Close Date are stored in GMT.  For EST (winter) - minus 5 hours.  For EDT (Summer) - minus 4 hours  

drop table ATTRFR
/


CREATE TABLE ATTRFR NOLOGGING NOCACHE AS
select DISTINCT TICKET_ID, STATE, REGION, CLEC_ID, 
       case when clec_id in ('ATX','AAV','SBB','SBZ','SUV','TPM') then 'ATX'||product else 'MOB'||product end company,
	   CKT_ID, PRODUCT, CREATE_DATE, 
       case when cleared_dt is null then closed_dt else cleared_dt end cleared_dt, 
       case when closed_dt is null then cleared_dt else closed_dt end closed_dt,
       TTR, TOTAL_DURATION, REPAIR_CODE, DISP, FOUND  
from (
select ticket_id, state, clec_id, cl.customer, ckt_id, product, create_date, cleared_dt, closed_dt,  
       ttr, total_duration, trbl_found_cd, trbl_found_desc, disp, 
	   CASE WHEN DISP IN ('CO','FAC','CC') THEN 'F'
	        WHEN DISP = 'NTF' THEN 'NF'
			ELSE 'EXC' END FOUND,
	   site_id, repair_code, serv_code,
	   case WHEN STATE IN ('NY','PA','CT') THEN 'OA1'
	        WHEN STATE IN ('MI','OH','WV','VA','MD') THEN 'OA2'
            WHEN STATE IN ('AL','FL','GA','MS','NC','SC','TN') THEN 'OA3'
       		WHEN STATE IN ('IA','IL','IN','MN','NE','WI','KY','MO') THEN 'OA4'
			WHEN STATE IN ('AZ','NV','NM','TX','UT') THEN 'OA5'
            WHEN STATE IN ('ID','MT','OR','WA') THEN 'OA6'
	  		WHEN STATE IN ('CA') THEN 'OA7'
	  	    ELSE 'Unknown' END REGION
from (
select distinct ticket_id, state, clec_id, ckt_id, 
       case when product in ('10M','100M') then '1G' else product end product,  
       create_date, cleared_dt, closed_dt, ttr, total_duration, 
	   case when trbl_found_number is not null then trbl_found_number
	        else trbl_found_number2 end trbl_found_cd,
	   case when trbl_found_desc is not null then trbl_found_desc
	        else trbl_found_desc2 end trbl_found_desc,		
	   case when disp3 is not null then disp3
	        when disp is not null then disp
	        else disp2 end disp, site_id,
       repair_code, serv_code  
from (
select distinct ticket_id, 
       case when icsc = 'RT01' then 'NY'
	        when substr(circuit,1,2) = 'R2' then 'NY'
	        when icsc = 'SN01' then 'CT'
	   		when site_state is not null  
	         and site_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then site_state
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
			when service_type_code = 'OB' THEN 'OCN'
			when service_type_code = 'OD' THEN 'OCN'
			when service_type_code = 'OF' THEN 'OCN'
			when service_type_code = 'OG' THEN 'OCN'
			when substr(circuit,1,10) like '%OC3%' then 'OCN'
            when substr(circuit,1,10) like '%OC03%' then 'OCN'
            when substr(circuit,1,10) like '%OC12%' then 'OCN'
            when substr(circuit,1,10) like '%OC48%' then 'OCN'
            when substr(circuit,1,10) like '%OC192%' then 'OCN'
			when substr(circuit,3,2) = 'OB' then 'OCN'
            when substr(circuit,3,2) = 'OD' then 'OCN'
            when substr(circuit,3,2) = 'OF' then 'OCN'
            when substr(circuit,3,2) = 'OG' then 'OCN'
            when service_type_code in ('KD','KP') then '10M'
            when service_type_code in ('KE','KQ') then '100M'    			
            when service_type_code in ('KF','KR') then '1G'
            when service_type_code in ('KG','KS') then '10G'
            when service_type_code = 'VL' then 'EVC'
            when substr(circuit,3,2) in ('KD','KP') then '10M'
            when substr(circuit,3,2) in ('KE','KQ') then '100M' 
            when substr(circuit,3,2) in ('KF','KR') then '1G'
            when substr(circuit,3,2) in ('KG','KS') then '10G'
			when substr(circuit,3,2) = 'VL' then 'EVC'
			when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
			else ' ' end product,
	   case when to_char(Create_Date,'yyyymmdd') between '20171105' AND '20180310' then Create_Date-5/24 
	        else Create_Date-4/24 end create_date, 
	   case when to_char(Cleared_Dt,'yyyymmdd') between '20171105' AND '20180310' then Cleared_dt-5/24
            when Cleared_Dt is not null then Cleared_dt-4/24
            when cleared_dt is null and to_char(Closed_Dt,'yyyymmdd') between '20171105' AND '20180310' then Closed_dt-5/24
	        else Closed_dt-4/24 end Cleared_Dt, 
	   case when to_char(Closed_Dt,'yyyymmdd') between '20171105' AND '20180310' then Closed_dt-5/24
            when Closed_Dt is not null then Closed_dt-4/24
            when closed_dt is null and to_char(Cleared_Dt,'yyyymmdd') between '20171105' AND '20180310' then Cleared_dt-5/24
	        else Cleared_dt-4/24 end Closed_Dt,
       Total_Duration, 
	   TTR,
	   b.trbl_found_number, b.trbl_found_desc, b.disp, c.trbl_found_number trbl_found_number2, c.trbl_found_desc trbl_found_desc2, c.disp disp2, d.disp disp3,
	   site_id, a.repair_code, serv_code
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
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (e.type <> 'T' or type is null) 
 and (to_char(dte_closeddatetime-5/24,'yyyymm') in ('201711','201712')    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') in ('201711','201712')))   --NEED TO CHANGE THIS EACH MONTH
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
)
--where state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX')
where clec_id in ('ATX','AAV','SBB','SBZ','SUV','TPM','AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   		    'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN',
				'BSM','CBL','CCB','CDA','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO',
			    'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL',
				'HGN','HLU','HNC','HTN','IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA',
			    'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB',
				'MWZ','NBC','NWW','OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN',
				'SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD',
				'VRA','WBT','WGL','WLG','WLZ','WVO','WWC','NHO')					  	 
)data, rvv827.carrier_list cl
where clec_id = cl.acna(+)
and product in ('DS0','DS1','DS3','OCN','Ethernet','10M','100M','1G','10G')
and disp in ('CO','FAC','CC','NTF') 
)					 
order by 4,3,1;




select region, state, company, ckt_id, ticket_id, disp, found, create_date, cleared_dt, closed_dt, 
to_char(closed_dt,'mm') mon 
from attrfr
order by 4,8; 


