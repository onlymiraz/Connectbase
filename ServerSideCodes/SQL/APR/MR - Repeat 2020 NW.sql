--The Cleared Date and Close Date are stored in GMT.  For EST (winter) - minus 5 hours.  For EDT (Summer) - minus 4 hours  

drop table APRMR
/

CREATE TABLE APRMR NOLOGGING NOCACHE AS
select region, TO_CHAR(CLOSED_DT,'YYYYMM') MONTH, ticket_id, CUSTOMER, CKT_ID, product, STATE, CLEC_ID, create_date, cleared_dt, closed_dt,
       repair_code, DISP, 
       case when disp = 'NTF' then 0 else ttr end ttr,  -- Per Matt Freeman on 1/30/2017  
       CASE WHEN DISP IN ('CO','FAC','CC','NTF') THEN 'Y' ELSE 'N' END  TTRDISP,
       CASE WHEN DISP IN ('CO','FAC') THEN 'Y' ELSE 'N' END  FFDISP, area, profile  
from (
select ticket_id, state, clec_id, cl.customer, ckt_id, product, create_date, cleared_dt, closed_dt,  
       ttr, total_duration, trbl_found_cd, trbl_found_desc, disp, site_id, repair_code, serv_code, profile,
	   case WHEN STATE IN ('NY','PA','CT') THEN 'East'
	        WHEN STATE IN ('MI','OH','WV','IA','IL','IN','MN','NE','WI','KY','MO') THEN 'Midwest'
            WHEN STATE IN ('AL','FL','GA','MS','NC','SC','TN','TX') THEN 'South'
			WHEN STATE IN ('AZ','NV','NM','UT','ID','MT','OR','WA','CA') THEN 'West'
	  	    ELSE 'Unknown' END REGION, area
from (
select distinct ticket_id, state, clec_id, ckt_id, product, create_date, 
       case when cleared_dt is null then closed_dt else cleared_dt end cleared_dt, 
       case when closed_dt is null then cleared_dt else closed_dt end closed_dt, 
       ttr, total_duration, 
	   case when trbl_found_number is not null then trbl_found_number
	        else trbl_found_number2 end trbl_found_cd,
	   case when trbl_found_desc is not null then trbl_found_desc
	        else trbl_found_desc2 end trbl_found_desc,		
	   case when disp3 is not null then disp3
	        when disp is not null then disp
	        else disp2 end disp, site_id,
       repair_code, serv_code, profile,
       case when state = 'CA' then 'CTF'
			else 'LEGACY' end area  
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
            when acna3 is not null then acna3
            else ccna2 end CLEC_ID, 		
       ckt_id,  
	   case when service_type_code = 'HC' then 'DS1'
			when service_type_code = 'HF' then 'DS3'
	   	 	when substr(circuit,4,5) like '%T1%' then 'DS1'
			when substr(circuit,4,5) like '%T3%' then 'DS3'
			when substr(circuit,1,4) like '%HC%' then 'DS1'
			when substr(circuit,1,4) like '%HF%' then 'DS3'
            when substr(circuit,1,4) like '%LX%' then 'DS3'
			when substr(circuit,1,2) = 'R2' then 'Ethernet'
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'
			when substr(service_type_code,1,2) = 'OC' then 'OCN'
			when substr(circuit,1,8) like '%OC%' then 'OCN'
			when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
            when substr(service_type_code,1,2) = 'SX' then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
            when substr(circuit,3,1) in ('X','L') then 'DS0'
			else ' ' end product,
	   create_date, 
	   case when Cleared_Dt is not null then Cleared_dt
            else Closed_dt end Cleared_Dt, 
	   case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,
       Total_Duration, 
	   TTR,
	   b.trbl_found_number, b.trbl_found_desc, b.disp, c.trbl_found_number trbl_found_number2, c.trbl_found_desc trbl_found_desc2, c.disp disp2, d.disp disp3,
	   site_id, a.repair_code, serv_code, icsc, clr, profile
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
       max(trim(d2.clec_id)) keep (dense_rank first order by d2.last_modified_date) acna3,
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
       max(substr(e.clr_notes,1,3)) keep (dense_rank last order by e.last_modified_date) clr,
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
       max(a.dw_load_date_time) keep (dense_rank last order by a.fld_modifieddate) load,
       max(trim(a.fld_assignmentprofile)) keep (dense_rank first order by a.fld_modifieddate) profile
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     rvv827.design_layout_report_temp d2,
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = d2.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (e.type <> 'T' or type is null) 
 and e.status (+) = '6'
 and (to_char(dte_closeddatetime,'yyyymm') in ('202003','202004')    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') in ('202003','202004')))   --NEED TO CHANGE THIS EACH MONTH
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
where state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX')
and clec_id in ('FET','FWN','BUC','BUR','CFA','AHY','ALI','ALN','AQH','ASC','ASI','AVD','AVZ','ENW','ESM','EYA','EYL','EYM','FAB','HSE',
              'HTJ','HTX','HWV','HYH','HYS','HYT','HYV','ICG','IMR','IPX','IXC','FLS','FOC','GIE','GSX','GTT','HAL','HCV','HDC','HDE',
			  'HFL','HGA','HIP','HKS','HMA','HMD','HNI','HNJ','HOH','HOR','HPA','HPM','CTO','EAS','PHY','LGG','LHT','LNH','LNK','LVC',
			  'LVW','MAD','NCY','NJF','NTT','NVN','SSM','SUR','TDT','VNL','VOY','WCA','WCU','WIZ','WLT','TTW','UNL','PUN','RTC','SCH',
			  'BEY','CAL','CGP','AEH','ATS','AWX','ENY','FDC','INA','JJJ','HOG','CRV','CWK','DGL','DTI','PAC','PHX','LCZ','LDW','LGT','MIV',
			  'LTL','TED','USW','UWB','UWC','UWI','VNS','TLX','QST','QWE','SEP','SML','SPA','BFC','BFP','BML','BTL','CBA','CDD','CFO','ONO',
			  'ADG','ADO','AKJ','AKV','ALS','ALU','ANI','ANW','APC','API','ATE','ELE','EMI','EXF','FAA','FED','FIB','ICF','ICI','ICT',
			  'IDB','IPC','ISC','ITD','ITT','ITW','JRL','FNE','CML','CNO','COE','COK','CPQ','CUI','CYG','CYT','CYY','DGX','DNI','EGI',
			  'OTN','LCI','LDD','LDL','LDS','LET','LNT','LSI','LSY','MAI','MAL','MAP','MAS','MAW','MCG','MCI','MCJ','MCK','MCX','MCY',
			  'MEC','MFD','MFS','MFZ','MIC','MLG','MLL','MPL','MPU','MRA','MSG','MST','MTD','MTF','MTY','MUR','NAS','NCQ','NFL','NLT',
			  'NTK','NTV','NWI','NWS','NYD','SYT','TAG','TCC','TDD','TEM','TEN','TET','UST','UUN','UVR','VGM','VIN','VUS','WDC','WDM',
			  'WTL','WUA','WUI','TFB','TFY','TGR','TIQ','TMN','TNC','TNO','TNW','TOA','TOM','TOR','TRI','TRT','TSF','TSG','TTM','TUH',
			  'TVT','TXO','TYR','UEL','UNF','RCG','SAN','SBS','SBX','SLS','SNC','SNS','SNT','SNW','ABW','APT','ICJ','OPT','PSO','WCG',
			  'TZV','PWR','SJV','AEY','IGW','ISA','GLF','GSP','GTS','GUS','CXE','CXJ','DCC','DCX','EIP','ONM','LCF','LDU','LPL','LSU',
			  'MJC','NEV','NLZ','NXT','STX','SUA','SWQ','SZC','USP','UTC','UTL','WEL','WOW','WSO','TNU','UBQ','ULG','ROW','SNK','SPC',
			  'SPV','CBU','CHL','AFY','AVS','FBL','ICU','IFC','IOR','IUT','GCW','GSM','GTC','CMA','CWV','PLI','NXO','USH','XMC','TIM',
			  'TIW','TQL','TQW','TWD','TWF','TWK','UHC','PTH','PUA','AAV','SUV','SBB','SBZ','ATX','TPM','BFL','BGH','BNY','BPN','BSM',
			  'BTE','CBL','CCB','CDA','CDP','CEJ','CEO','CEU','CFN','CGH','CIF','CIV','CKQ','AAX','ACF','ACH','ADM','AEC','AGS','AGZ',
			  'AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AUA','AUR','AUZ','AWL','AWN','AXD','AZE','BAC','BAK',
			  'BAO','BCU','EKC','EST','ETP','ETX','EWC','FLA','HTN','HWC','IFP','IMP','IND','ISZ','IUW','JCT','FSC','FSI','FSV','GEE',
			  'GLV','GSL','HGN','HLN','HLU','HNC','HRN','CLQ','COW','CQW','CRF','CRJ','CSG','CSO','CSU','CSX','CTJ','CUO','CXA','CZB',
			  'DBY','DIC','DNC','DUT','ORV','OSU','PCK','PCW','PFM','PIG','PKG','KYR','LAA','LAC','LBH','LHR','LNZ','LSZ','MBQ','MCA',
			  'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MKN','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MUM','MWB','MWZ',
			  'NBC','NHO','NPW','OAK','OCL','STH','SUF','SVU','SWM','SWP','SWT','SWV','SYC','SYG','SZM','VGD','VRA','WBT','WCX','WGL',
			  'WLG','WLZ','WVO','WWC','YBG','TGH','TQU','UMT','RAD','RFC','RMC','RMF','RRC','SBG','SBM','SBN','SCU','SCZ','SHI','SLL','SMC','SNP',
			  'BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','AAK','AHG','AKR','AOK','AUL','BAM','BBK','FCO','FCS','IAP','ICN','IDE','IPD',
			  'JCC','KOC','FMN','FNT','GAF','GEX','GMB','GMT','GNL','GTB','GTE','GVU','CLW','CMO','CNL','CNN','COQ','CRB','CRR','CRY',
			  'CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG','DYT','EBA','ECT','OHC','OMC','PCF','PLP','PPM','LCN','LSC','LTT','MBN',
			  'MCB','MJP','MMH','MMO','NBT','NOH','NVC','NYM','NYR','SRY','SZP','TDQ','TDU','UTI','UTS','VRZ','ULN','UNV','PTE','PTG',
			  'PTI','PTM','PUL','RMB','RMD','SOT','AYD','DVN','ELG','OGT','ORO','PCL','UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL',
			  'RVY','TNR','UCL','USC','WCT','HOC','UXW','CPO','NVA','LTP','DLT','BTI','NGE','AEJ','AVJ','AWH','BMJ','CJG','CND',
			  'ENA','EXE','FDN','FDW','FRG','GBU','KDL','LDM','LTT','MWR','MZJ','NLG','NNN','NSC','OLP','PFT','TAD','VAU','VLO','WSJ',
			  'YOH','YVA','ALG','AMM','ARJ','CAB','CCK','CDN','CPK','DLM','DOV','FEL','IOR','LCG','LDN','LDO','LDR','LMI','LOG','LWK',
			  'NKH','OCB','OVT','PHG','PUA','SGY','TVC','TVN','UHC','VLR','VPM','TFU','NVE','DSG','AZC','SHO','TZJ',
              'AFW','AXJ','CRZ','GRM','LRS','PYQ','TTU','UWT','VAF','VLK','BAL','NKV','MTV','DSE','EPO','GBS','GBW','IZC','LKG','MOQ',
              'NAO','OER','OVC','SXY','UVA','GIM')		 
)
data, rvv827.carrier_list cl
where clec_id = cl.acna(+)
and data.product in ('DS0','DS1','DS3','OCN','Ethernet')
--and (disp in ('CO','FAC','CC','NTF') or disp is null)
)
where state in ('WA','OR','ID','MT')					 
order by 4,3,1;






--  TO PULL THE DETAIL FOR THE APR REPORT   

SELECT TICKET_ID, CUSTOMER, CKT_ID, PRODUCT SERVICE, STATE, AREA, CLEC_ID ACNA, CREATE_DATE, CLEARED_DT CLEARED_DATE,
       CLOSED_DT CLOSE_DATE, REPAIR_CODE, DISP TRBL_GROUP, round(TTR,2) TTR
FROM APRMR
WHERE MONTH = '202004'
--WHERE CUSTOMER = 'US CELLULAR'
--AND MONTH = '201710'
ORDER BY CUSTOMER, CLOSED_DT;



select * from aprmr
where month = '202004'
order by 4,3;


select * from aprmr
where month = '202004'
and customer in ('US CELLULAR','SPRINT PCS')
and product = 'Ethernet'
and disp in ('FAC','CO');


--  TO PULL THE DETAIL FOR THE RFR NUMERATOR  

drop table aprrepeat
/

create table aprrepeat nologging nocache as
select * 
from aprmr
where to_char(closed_dt,'MM')  = '04'    --NEED TO CHANGE THIS EACH MONTH
and disp in ('CO','FAC');



select ticket_id, state, clec_id, customer, product,
       ckt_id, create_date, cleared_dt, closed_dt, disp, prev_ticket_id, prev_create_dt, prev_clear_dt,
       prev_disp, round(create_date-prev_clear_dt,0) days, to_char(closed_dt,'MM') mon 
from (
select r.ticket_id, r.state, r.clec_id, r.customer,
       r.product, r.ckt_id, r.create_date, r.cleared_dt, r.closed_dt, r.disp, 
       max(t.ticket_id) prev_ticket_id, 
       max(t.create_date) prev_create_dt, 
       max(t.cleared_dt) prev_clear_dt,
       max(t.disp) prev_disp 
from aprrepeat r, aprmr t 
where r.CKT_ID = t.ckt_id
and r.CREATE_DATE > t.CLEARED_DT
and r.ticket_id <> t.ticket_id
and t.disp in ('CO','FAC','NTF','CC')
group by r.ticket_id, r.state, r.clec_id, r.customer,
         r.product, r.ckt_id, r.create_date, r.cleared_dt, r.closed_dt, r.disp
)
where create_date-prev_clear_dt <=30
order by 4,5,6,7,1;


