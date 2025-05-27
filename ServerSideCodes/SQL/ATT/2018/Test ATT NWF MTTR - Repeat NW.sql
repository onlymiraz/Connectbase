 
drop table ATTMR
/

CREATE TABLE ATTMR NOLOGGING NOCACHE AS
select DISTINCT TICKET_ID, STATE, CLEC_ID, COMPANY, CKT_ID, PRODUCT, PROD2, BDW, CREATE_DATE,
       case when cleared_dt is null then closed_dt else cleared_dt end cleared_dt, 
       case when closed_dt is null then cleared_dt else closed_dt end closed_dt, 
       case when disp = 'NTF' then 0 else ttr end ttr,  -- Per Matt Freeman on 1/30/2017  
       REPAIR_CODE, DISP,
	   CASE WHEN TTR between 4.01 and 24 THEN 1 ELSE 0 END TTR4to24,
	   CASE WHEN TTR between 8.01 and 24 THEN 1 ELSE 0 END TTR8to24,
       CASE WHEN TTR between 24.01 and 48 THEN 1 ELSE 0 END TTR24to48,
       CASE WHEN TTR between 48.01 and 72 THEN 1 ELSE 0 END TTR48to72,
       CASE WHEN TTR between 72.01 and 96 THEN 1 ELSE 0 END TTR72to96,
       CASE WHEN TTR >96 THEN 1 ELSE 0 END TTR96,
	   CASE WHEN CAUSE_CD = 'Fiber/Cable - Cut' then 'Y' 
            WHEN FAULT = '11' THEN 'Y'
            WHEN PLANT IN ('0312','0344') THEN 'Y'
            ELSE 'N' end CABLE_CUT, 
       CASE WHEN DISP IN ('CO','FAC') THEN 'Y' ELSE 'N' END FOUND, cause_cd, 
       trouble_desc, to_char(closed_dt,'MM') mon
from (
select ticket_id, state, clec_id, cl.customer, ckt_id, product,
       case when product in ('DS1') and company = 'ATX' then 'ABS DS1'
            when product in ('DS3') and company = 'ATX' then 'ABS DS3'
            when product in ('OCN') and company = 'ATX' then 'ABS OCN'
            when product in ('Ethernet') and company = 'ATX' then 'ABS Ethernet'       
            when product in ('DS1','DS3','OCN') and company = 'MOB' then 'Exclude'  
            when product = 'Ethernet' and company = 'MOB' and bdw = '1G' then 'MOB 1G' 
            when product = 'Ethernet' and company = 'MOB' and bdw = '10G' then 'MOB 10G'
            else null end prod2, 
       create_date, cleared_dt, closed_dt, TTR,  
       total_duration, trbl_found_cd, trbl_found_desc, disp,
	   site_id, repair_code, service_type_code,
			cause_cd, company, bdw, fault, plant, trouble_desc
from (
select distinct ticket_id, state, clec_id, ckt_id, product, 
       case when clec_id in ('ATX','AAV','SBB','SBZ','SUV','TPM','LOA','AVA','AYA') then 'ATX' else 'MOB' end company,
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
       repair_code, service_type_code, cause_cd, fault, plant, trouble_desc
from (
select distinct ticket_id, 
       case when site_state is not null and site_id <> 'NON INVENTORIED CIRCUIT'  
	         and site_state in ('OR','WA','ID','MT') then site_state
            when priloc is not null 
			 and priloc in ('OR','WA','ID','MT') then priloc
            else null end state,
       case when acna is not null then acna
            when ccna1 is not null then ccna1
            when ccna2 is not null then ccna2
	        else acna3 end CLEC_ID, 		
       ckt_id,  
	   case when service_type_code = 'HC' then 'DS1'
			when service_type_code = 'HF' then 'DS3'
            when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
            when service_type_code in ('OB','OD','OF','OG') then 'OCN'
            when substr(service_type_code,1,1) in ('X','L') then 'DS0'
	   	 	when substr(circuit,4,5) like '%T1%' then 'DS1'
			when substr(circuit,4,5) like '%T3%' then 'DS3'
			when substr(circuit,1,4) like '%HC%' then 'DS1'
			when substr(circuit,1,4) like '%HF%' then 'DS3'
			when substr(circuit,1,2) = 'R2' then 'Ethernet'	
			when substr(circuit,3,1) in ('X','L') then 'DS0'
			when substr(circuit,1,10) like '%OC3%' then 'OCN'
            when substr(circuit,1,10) like '%OC03%' then 'OCN'
            when substr(circuit,1,10) like '%OC12%' then 'OCN'
            when substr(circuit,1,10) like '%OC48%' then 'OCN'
            when substr(circuit,1,10) like '%OC192%' then 'OCN'
			when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
			else ' ' end product,
	   Create_Date, 
	   case when Cleared_Dt is not null then Cleared_dt
            else Closed_dt end Cleared_Dt, 
	   case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,
       Total_Duration, 
	   TTR,
	   b.trbl_found_number, b.trbl_found_desc, b.disp, c.trbl_found_number trbl_found_number2, c.trbl_found_desc trbl_found_desc2, c.disp disp2, d.disp disp3,
	   site_id, a.repair_code, service_type_code, cause_cd, fault, plant, trouble_desc
from (
select a.fld_requestid ticket_id, 
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
	   a.exchange_carrier_circuit_id ckt_id, 
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
	   max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1, 
	   max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,
       max(trim(d2.clec_id)) keep (dense_rank first order by d2.last_modified_date) acna3,
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
       max(vnet.fault_plant_item) keep (dense_rank first order by vnet.dw_load_date_time) plant,
       replace(replace(A.FLD_DESCRIPTIONOFSYMPTON,chr(10),''),chr(13),'') TROUBLE_DESC
from casdw.trouble_ticket_r a,  
     casdw.work_order_r wo,
     casdw.design_layout_report d,
     rvv827.design_layout_report_temp d2,
     casdw.circuit e,
     casdw.vnet_daily vnet
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')
 and a.fld_requestid = wo.fld_ticketid (+)
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = d2.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and substr(wo.fld_requestid,9,7) = substr(vnet.host_id (+),10,7)
 and (e.type <> 'T' or type is null) 
 and (to_char(dte_closeddatetime,'yyyymm') in ('202004','202005')    --NEED TO CHANGE THIS EACH MONTH TO INCLUDE BOTH CURRENT AND PREVIOUS MONTHS 
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') in ('202004','202005')))   --NEED TO CHANGE THIS EACH MONTH TO INCLUDE BOTH CURRENT AND PREVIOUS MONTHS 
 and e.status (+) = '6'
 and d.ccna in ('ATX','AAV','SBB','SBZ','SUV','TPM','AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   		    'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN',
				'BSM','CBL','CCB','CDA','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO',
			    'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL',
				'HGN','HLU','HNC','HTN','IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA',
			    'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB',
				'MWZ','NBC','NWW','OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN',
				'SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD',
				'VRA','WBT','WGL','WLG','WLZ','WVO','WWC','NHO','LOA','AVA','AYA')
group by a.fld_requestid, a.exchange_carrier_circuit_id, A.FLD_DESCRIPTIONOFSYMPTON
) a, rvv827.trbl_found_remedy b, rvv827.repair_code c, rvv827.trbl_found_remedy d
where a.trbl_found_cd = b.trbl_found_number (+)
and a.repair_code = c.repair_code (+)
and a.repair_code = d.trbl_found_desc (+) 
and substr(circuit,6,1) <> 'U'   
and request_type in ('Agent','Alarm','Customer','Maintenance')
and substr(ckt_id,4,2) not in ('VM','EM','IP','IB','FX','YB','YG','UG','UH','RT','PL','LA','LU','XA','LA','LO','LN','LU','FD','US','CS')   
and reqstat = 'Closed' 
)
where clec_id in ('ATX','AAV','SBB','SBZ','SUV','TPM','AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   		    'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN',
				'BSM','CBL','CCB','CDA','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO',
			    'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL',
				'HGN','HLU','HNC','HTN','IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA',
			    'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB',
				'MWZ','NBC','NWW','OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN',
				'SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD',
				'VRA','WBT','WGL','WLG','WLZ','WVO','WWC','NHO','LOA','AVA','AYA')					  	 
)data, rvv827.carrier_list cl
where clec_id = cl.acna(+)
and product in ('DS1','DS3','OCN','Ethernet')
)	
where state in ('WA','OR','ID','MT')
and prod2 in ('ABS DS1','ABS DS3','ABS OCN','ABS Ethernet','MOB 1G','MOB 10G')				 
order by 4,3,1;





--MTTR    
select * from attmr
where mon = '05'   --NEED TO CHANGE THIS EACH MONTH TO SHOW CURRENT MONTH 
and disp in ('CO','FAC','CC','NTF')
;


drop table attrepeat
/

create table attrepeat nologging nocache as
select * 
from attmr
where mon = '05'   --NEED TO CHANGE THIS EACH MONTH TO SHOW CURRENT MONTH 
and disp in ('CO','FAC','NTF','CC');


--Pulls the summary RFR to put on the RFR tab   
select company, product, bdw, count(*) cnt
from (
select ticket_id, state, clec_id, company, product, bdw,
       ckt_id, create_date, cleared_dt, closed_dt, disp, prev_ticket_id, prev_create_dt, prev_clear_dt,
       prev_disp, round(create_date-prev_clear_dt,0) days, to_char(closed_dt,'MM') mon 
from (
select r.ticket_id, r.state, r.clec_id, r.company, 
       r.product, r.ckt_id, r.create_date, r.cleared_dt, r.closed_dt, r.disp, r.bdw,
       max(t.ticket_id) prev_ticket_id, 
       max(t.create_date) prev_create_dt, 
       max(t.cleared_dt) prev_clear_dt,
       max(t.disp) prev_disp 
from attrepeat r, attmr t 
where r.CKT_ID = t.ckt_id
and r.CREATE_DATE > t.CLEARED_DT
and r.ticket_id <> t.ticket_id
and t.disp in ('CO','FAC','NTF','CC')
group by r.ticket_id, r.state, r.clec_id, r.company, 
         r.product, r.ckt_id, r.create_date, r.cleared_dt, r.closed_dt, r.disp, r.bdw
)
where create_date-prev_clear_dt <=30
)
group by company, product, bdw
order by 1,2,3,4;






--Pulls the detail for the repeat and the associated troubles  
drop table attrpt
/
;

create table attrpt nologging nocache as
select ckt_id, ticket_id, round(create_date-prev_clear_dt,0) days, 1 rpt 
from (
select r.ticket_id, r.state, r.clec_id, r.company, 
       r.product, r.ckt_id, r.create_date, r.cleared_dt, r.closed_dt, r.disp, 
       max(t.ticket_id) prev_ticket_id, 
       max(t.create_date) prev_create_dt, 
       max(t.cleared_dt) prev_clear_dt,
       max(t.disp) prev_disp 
from attrepeat r, attmr t 
where r.CKT_ID = t.ckt_id
and r.CREATE_DATE > t.CLEARED_DT
and r.ticket_id <> t.ticket_id
and t.disp in ('CO','FAC','NTF','CC')
group by r.ticket_id, r.state, r.clec_id, r.company, 
         r.product, r.ckt_id, r.create_date, r.cleared_dt, r.closed_dt, r.disp
)
where create_date-prev_clear_dt <=30
;



select state, company, product, t2.ckt_id, t2.ticket_id, disp, found, create_date, cleared_dt, closed_dt, days, rpt  
from attmr t2, attrpt r2
where t2.ticket_id = r2.ticket_id (+) 
and t2.ckt_id in (select ckt_id from attrpt)
and disp in ('CO','FAC','NTF','CC')
order by 4,8;


