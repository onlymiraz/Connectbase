--The Cleared Date and Close Date are stored in GMT.  For EST (winter) - minus 5 hours.  For EDT (Summer) - minus 4 hours  

--drop table ATTMR
--/

--CREATE TABLE ATTMR NOLOGGING NOCACHE AS
select DISTINCT TICKET_ID, STATE, REGION, CLEC_ID, COMPANY, CKT_ID, PRODUCT, PROD2, BDW, CREATE_DATE,
       case when cleared_dt is null then closed_dt else cleared_dt end cleared_dt, 
       case when closed_dt is null then cleared_dt else closed_dt end closed_dt, 
       case when disp = 'NTF' then 0 else ttr end ttr,  -- Per Matt Freeman on 1/30/2017  
       REPAIR_CODE, DISP,
	   CASE WHEN TTR between 4.01 and 8 THEN 1 ELSE 0 END TTR4to8,
	   CASE WHEN TTR between 8.01 and 24 THEN 1 ELSE 0 END TTR8to24,
       CASE WHEN TTR between 24.01 and 48 THEN 1 ELSE 0 END TTR24to48,
       CASE WHEN TTR between 48.01 and 72 THEN 1 ELSE 0 END TTR48to72,
       CASE WHEN TTR between 72.01 and 96 THEN 1 ELSE 0 END TTR72to96,
       CASE WHEN TTR >96 THEN 1 ELSE 0 END TTR96,
	   CASE WHEN CAUSE_CD = 'Fiber/Cable - Cut' then 'Y' 
            WHEN FAULT = '11' THEN 'Y'
            WHEN PLANT IN ('0312','0344') THEN 'Y'
            ELSE 'N' end CABLE_CUT, 
       CASE WHEN DISP IN ('CO','FAC') THEN 'Y' ELSE 'N' END FOUND, cause_cd
from (
select ticket_id, state, clec_id, cl.customer, ckt_id, product,
       case when product in ('DS1','DS3','OCN','Ethernet') and company = 'ATX' then 'ABS All'
            when product in ('DS1','DS3','OCN') and company = 'MOB' then 'Exclude'  
            when product = 'Ethernet' and company = 'MOB' and bdw = '1G' then 'MOB 1G' 
            when product = 'Ethernet' and company = 'MOB' and bdw = '10G' then 'MOB 10G'
            else null end prod2, 
       create_date, cleared_dt, closed_dt, TTR,  
       total_duration, trbl_found_cd, trbl_found_desc, disp,
	   site_id, repair_code, service_type_code,
	   case WHEN STATE IN ('NY','PA','CT') THEN 'OA1'
	        WHEN STATE IN ('MI','OH','WV','VA','MD') THEN 'OA2'
            WHEN STATE IN ('AL','FL','GA','MS','NC','SC','TN') THEN 'OA3'
       		WHEN STATE IN ('IA','IL','IN','MN','NE','WI','KY','MO') THEN 'OA4'
			WHEN STATE IN ('AZ','NV','NM','TX','UT') THEN 'OA5'
            WHEN STATE IN ('ID','MT','OR','WA') THEN 'OA6'
	  		WHEN STATE IN ('CA') THEN 'OA7'
	  	    ELSE 'Unknown' END REGION,
			cause_cd, company, bdw, fault, plant
from (
select distinct ticket_id, state, clec_id, ckt_id, product, 
       case when clec_id in ('ATX','AAV','SBB','SBZ','SUV','TPM') then 'ATX' else 'MOB' end company,
       case when product = 'Ethernet' and service_type_code in ('KF','KR') then '1G'
            when product = 'Ethernet' and service_type_code in ('KG','KS') then '10G'
            when product = 'Ethernet' and service_type_code in ('KE','KQ') then '1G'   --100M, but counted as 1G  
            when product = 'Ethernet' and service_type_code in ('KD','KP') then '1G'   --10M, but counted as 1G  
            when product = 'Ethernet' and service_type_code in ('VL') then 'EVC' 
            when product in ('DS1','DS3','OCN') then null
            else 'Check' end bdw,    
       create_date, cleared_dt, closed_dt, ttr, total_duration, 
	   case when trbl_found_number is not null then trbl_found_number
	        else trbl_found_number2 end trbl_found_cd,
	   case when trbl_found_desc is not null then trbl_found_desc
	        else trbl_found_desc2 end trbl_found_desc,		
	   case when disp3 is not null then disp3
	        when disp is not null then disp
	        else disp2 end disp, site_id,
       repair_code, service_type_code, cause_cd, fault, plant
from (
select distinct ticket_id, 
       case when icsc = 'RT01' then 'NY'
	        when substr(circuit,1,2) = 'R2' then 'NY'
	        when icsc = 'SN01' then 'CT'
	   		when site_state is not null and site_id <> 'NON INVENTORIED CIRCUIT'  
	         and site_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then site_state
            when priloc is not null 
			 and priloc in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then priloc
		    when icsc = 'FV01' then 'WV'
			when ckt_id like '%/WV%' then 'WV'
		    when substr(circuit,1,2) in ('50','54','56') then 'WV'
            else null end state,
       case when acna is not null then acna
            else acna2 end CLEC_ID, 		
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
			when service_type_code in ('OB','OD','OF','OG') then 'OCN'
			when substr(circuit,1,10) like '%OC3%' then 'OCN'
            when substr(circuit,1,10) like '%OC03%' then 'OCN'
            when substr(circuit,1,10) like '%OC12%' then 'OCN'
            when substr(circuit,1,10) like '%OC48%' then 'OCN'
            when substr(circuit,1,10) like '%OC192%' then 'OCN'
			when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
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
	   site_id, a.repair_code, service_type_code, cause_cd, fault, plant
from (
select a.fld_requestid ticket_id, 
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
	   a.exchange_carrier_circuit_id ckt_id, 
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
	   max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna,
	   max(d.acna) keep (dense_rank first order by d.acna) acna2,
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
	   max(round(a.h_fld_totalopentime_secs_/3600,2)) keep (dense_rank last order by a.fld_modifieddate) Total_Duration,
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
	   max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,
       max(fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) cause_cd,
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
       max(wo.fld_requestid) keep (dense_rank first order by wo.fld_auditmodifieddate) wo_id,
       max(vnet.fault_fault) keep (dense_rank first order by vnet.dw_load_date_time) fault,
       max(vnet.fault_plant_item) keep (dense_rank first order by vnet.dw_load_date_time) plant
from casdw.trouble_ticket_r a,  
     casdw.work_order_r wo,
     casdw.design_layout_report d,
     casdw.circuit e,
     casdw.vnet_daily vnet
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')
 and a.fld_requestid = wo.fld_ticketid (+)
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and substr(wo.fld_requestid,9,7) = substr(vnet.host_id (+),10,7)
 and (e.type <> 'T' or type is null) 
 and (to_char(dte_closeddatetime-5/24,'yyyymm') = '201712'    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') = '201712'))   --NEED TO CHANGE THIS EACH MONTH
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
and product in ('DS1','DS3','OCN','Ethernet')
and disp in ('CO','FAC','CC','NTF')
)					 
order by 4,3,1;









select * from attmr;



--For Mid-Month pull  

select * from attmr
where prod2 <> 'Exclude';










SELECT '1- % Tickets' METRIC, 'ABS All' PROD, COUNT(*) NUM, NULL DEN
FROM ATTMR   
WHERE COMPANY = 'ATX'
--
UNION ALL
--
SELECT '1- % Tickets', 'MOB 1G', COUNT(*) NUM, NULL DEN
FROM ATTMR   
WHERE COMPANY = 'MOB'
AND BDW = '1G'
--
UNION ALL
--
SELECT '1- % Tickets', 'MOB 10G', COUNT(*) NUM, NULL DEN
FROM ATTMR   
WHERE COMPANY = 'MOB'
AND BDW = '10G'
--
UNION ALL
--
SELECT '2.2a- MTTR MEAS', 'ALL', SUM(TTR) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE (COMPANY = 'ATX' OR (COMPANY = 'MOB' AND BDW IN ('1G','10G')))
--
UNION ALL
--
SELECT '2.2b- MTTR MEAS - CUT', 'ALL', SUM(TTR) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE (COMPANY = 'ATX' OR (COMPANY = 'MOB' AND BDW IN ('1G','10G')))
AND CABLE_CUT = 'Y'
--
UNION ALL
--
SELECT '2.2b- MTTR MEAS - NO CUT', 'ALL', SUM(TTR) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE (COMPANY = 'ATX' OR (COMPANY = 'MOB' AND BDW IN ('1G','10G')))
AND CABLE_CUT = 'N'
--
UNION ALL
--
SELECT '2.2c- MTTR MEAS', COMPANY||' '||PRODUCT, SUM(TTR) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'ATX' 
GROUP BY COMPANY, PRODUCT
--
UNION ALL
--
SELECT '2.2c- MTTR MEAS', COMPANY||' '||PRODUCT||' '||BDW, SUM(TTR) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'MOB' AND BDW IN ('1G','10G')
GROUP BY COMPANY, PRODUCT, BDW
--
UNION ALL
--
SELECT '2.3- MTTR GT4', 'ABS ALL', SUM(TTR) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'ATX'
AND TTR > 4
--
UNION ALL
--
SELECT '2.4- TTR w/i 4', 'ABS DS1', SUM(TTR4) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'ATX' AND PRODUCT = 'DS1'
--
UNION ALL
--
SELECT '2.4- TTR w/i 4', 'ABS DS3/OCN/ETH', SUM(TTR4) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'ATX' AND PRODUCT IN ('DS3','OCN','Ethernet')
--
UNION ALL
--
SELECT '2.4- TTR w/i 4', 'MOB 10G', SUM(TTR4) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'MOB' AND BDW = '10G'
--
UNION ALL
--
SELECT '2.5- TTR w/i 24', 'MOB 1G', SUM(TTR24) NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'MOB' AND BDW = '1G'
--
UNION ALL
--
SELECT '2.6- RFR', 'ATX DS1', NULL NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'ATX' AND PRODUCT = 'DS1'
--
UNION ALL
--
SELECT '2.6- RFR', COMPANY||' '||PRODUCT, NULL NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'ATX' AND PRODUCT IN ('DS3','OCN')
GROUP BY COMPANY, PRODUCT
--
UNION ALL
--
SELECT '2.6- RFR', 'BOTH 1G/10G', NULL NUM, COUNT(*) DEN
FROM ATTMR   
WHERE BDW IN ('1G','10G')
--
UNION ALL
--
SELECT '2.6- RFR', COMPANY||' '||BDW, NULL NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'MOB' AND BDW IN ('1G','10G')
GROUP BY COMPANY, BDW
--
UNION ALL
--
SELECT '2.7- # TICKETS > 4', 'MOB 10G', NULL NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'MOB' AND BDW = '10G'
AND TTR > 4
--
UNION ALL
--
SELECT '2.7- # TICKETS > 24', 'MOB 1G', NULL NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'MOB' AND BDW = '1G'
AND TTR > 24
--
UNION ALL
--
SELECT '2.7- # TICKETS > 48', 'MOB 1G', NULL NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'MOB' AND BDW = '1G'
AND TTR > 48
--
UNION ALL
--
SELECT '2.7- # TICKETS > 72', 'MOB 1G', NULL NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'MOB' AND BDW = '1G'
AND TTR > 72
--
UNION ALL
--
SELECT '2.7- # TICKETS > 96', 'MOB 1G', NULL NUM, COUNT(*) DEN
FROM ATTMR   
WHERE COMPANY = 'MOB' AND BDW = '1G'
AND TTR > 96
ORDER BY 1, 2;





