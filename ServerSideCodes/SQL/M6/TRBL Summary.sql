select region, state,ticket_id, assignmentprofile, product, TO_CHAR(CLOSED_DT,'YYYYMM') MONTH, create_date, cleared_dt, closed_dt, ckt_id, 
       clec_id, customer, repair_code, disp, cause_cd, ttr 
from (
select ticket_id, state,   
       case when area is not null then area
            WHEN STATE IN ('CT','NY','PA','AL','FL','GA','MS','NC','SC','TN') then 'Eastern'
            WHEN STATE IN ('IA','IL','IN','MI','MN','NE','WI','KY','TX','OH','WV','MD','VA') then 'Central'
       		WHEN STATE IN ('CA','AZ','NM','NV','UT') then 'Western'
            else null end region,
       territory, director, clec_id, customer, ckt_id, product, create_date, cleared_dt, closed_dt,  
       case when disp = 'NTF' then 0 else ttr end ttr,  -- Per Matt Freeman on 1/30/2017  
       repair_code, cause_cd, disp, clli_code site_clli,
       reqstat, location_name, assignmentprofile,
       CASE WHEN CAUSE_CD = 'Frontier Fiber Cut (Not Frontier Caused)' then 'Yes - Not Frontier' 
            WHEN CAUSE_CD = 'Frontier Fiber Cut (Frontier Caused)' then 'Yes - Frontier' 
            WHEN CAUSE_CD = 'FIBER_CUT' then 'Yes - Frontier' 
            ELSE 'No' end CABLE_CUT
from (
select distinct ticket_id, clec_id, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, total_duration, repair_code, cause_cd, disp, 
       reqstat, location_name, cl.customer, assignmentprofile,
       case when site_state is not null 
             and site_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','AZ','NV','NM','UT','WI','IA','NE','AL','FL','GA','MS','TN','TX') then site_state
            when clliz_state is not null 
             and clliz_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','AZ','NV','NM','UT','WI','IA','NE','AL','FL','GA','MS','TN','TX') then clliz_state
            when exchz_state is not null 
             and exchz_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','AZ','NV','NM','UT','WI','IA','NE','AL','FL','GA','MS','TN','TX') then exchz_state
            when cllia_state is not null 
             and cllia_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','AZ','NV','NM','UT','WI','IA','NE','AL','FL','GA','MS','TN','TX') then cllia_state 
            when priloc_state is not null 
             and priloc_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','AZ','NV','NM','UT','WI','IA','NE','AL','FL','GA','MS','TN','TX') then priloc_state
            when final_state is not null
             and final_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','AZ','NV','NM','UT','WI','IA','NE','AL','FL','GA','MS','TN','TX') then final_state
            when substr(ckt_id,1,2) in ('81','45') then 'CA'
            when substr(ckt_id,1,2) in ('69','65') then 'FL'
            when substr(ckt_id,1,2) in ('12','13') then 'TX'
            when icsc = 'RT01' then 'NY'
            when icsc = 'SN01' then 'CT'
            end state,
       case when site_area is not null then site_area
            when clliz_area is not null then clliz_area
            when exchz_area is not null then exchz_area
            when cllia_area is not null then cllia_area
            when pri_area is not null then pri_area
            when actl_area is not null then actl_area
            when mux_area is not null then mux_area
            else null end area,
       case when site_ter is not null then site_ter
            when clliz_ter is not null then clliz_ter
            when exchz_ter is not null then exchz_ter
            when cllia_ter is not null then cllia_ter
            when pri_ter is not null then pri_ter
            when actl_ter is not null then actl_ter
            when mux_ter is not null then mux_ter
            else null end territory, 
       case when site_dir is not null then site_dir
            when clliz_dir is not null then clliz_dir
            when exchz_dir is not null then exchz_dir
            when cllia_dir is not null then cllia_dir
            when pri_dir is not null then pri_dir
            when actl_dir is not null then actl_dir
            when mux_dir is not null then mux_dir
            else null end director,
       site_clli, site_area, site_ter, site_dir, site_state,
       clliz_clli, clliz_area, clliz_ter, clliz_dir, clliz_state,
       exchz_clli, exchz_area, exchz_ter, exchz_dir, exchz_state,
       cllia_clli, cllia_area, cllia_ter, cllia_dir, cllia_state,
       pri_clli, pri_area, pri_ter, pri_dir, pri_state,
       actl_clli, actl_area, actl_ter, actl_dir, actl_state,
       mux_clli, mux_area, mux_ter, mux_dir, mux_state, clli_code                           
from (
select distinct ticket_id, priloc_state, 
       case when acna is not null then acna
            when acna1 is not null then acna1
            when ccna1 is not null then ccna1
            when acna2 is not null then acna2
            else ccna2 end CLEC_ID,        
       ckt_id, icsc,
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
            when substr(service_type_code,1,2) = 'SX' then 'Ethernet'
            when substr(circuit,3,1) in ('K','V') then 'Ethernet'
            when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
            else ' ' end product,
       create_date, Cleared_Dt, 
       case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,
       Total_Duration, TTR, a.repair_code, cause_cd, b.disp, reqstat,  
       replace(replace(location_name, chr(13)),chr(10)) location_name, assignmentprofile,
       dir1.clli site_clli, dir1.area site_area, dir1.territory site_ter, dir1.director site_dir, dir1.state site_state,
       dir2.clli clliz_clli, dir2.area clliz_area, dir2.territory clliz_ter, dir2.director clliz_dir, dir2.state clliz_state,
       dir3.clli exchz_clli, dir3.area exchz_area, dir3.territory exchz_ter, dir3.director exchz_dir, dir3.state exchz_state,
       dir4.clli cllia_clli, dir4.area cllia_area, dir4.territory cllia_ter, dir4.director cllia_dir, dir4.state cllia_state,
       dir5.clli pri_clli, dir5.area pri_area, dir5.territory pri_ter, dir5.director pri_dir, dir5.state pri_state,
       dir6.clli actl_clli, dir6.area actl_area, dir6.territory actl_ter, dir6.director actl_dir, dir6.state actl_state,
       dir7.clli mux_clli, dir7.area mux_area, dir7.territory mux_ter, dir7.director mux_dir, dir7.state mux_state,
       case when site_clli6 is not null and site_clli6 <> 'NOT IN' then site_clli6
            when clliz is not null then clliz
            else cllia end clli_code,
       case when site_clli6 is not null and site_clli6 <> 'NOT IN' then substr(site_clli6,5,2)
            when clliz is not null then substr(clliz,5,2)
            when exch_clliz is not null then substr(exch_clliz,5,2) 
            else substr(cllia,5,2) end final_state 
from (
select ticket_id, site_clli6, site_state, rem_state, ckt_id, circuit, z.acna, request_type, create_date,
       cleared_dt, closed_dt, ttr, total_duration, repair_code, reqstat, z.location_name,
       assignmentprofile, service_type_code, rate_code, cause_cd,
       max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc_state,
       max(substr(d.primary_location,1,6)) keep (dense_rank last order by d.last_modified_date) priloc,
       max(substr(d.access_cust_terminal_location,1,6)) keep (dense_rank last order by d.last_modified_date) actl,
       max(substr(d.mux_location,1,6)) keep (dense_rank last order by d.last_modified_date) mux,        
       max(substr(f.clli_code,5,2)) keep (dense_rank last order by f.last_modified_date) cllia_state,
       max(substr(f2.clli_code,5,2)) keep (dense_rank last order by f2.last_modified_date) clliz_state,
       max(trim(d.acna)) keep (dense_rank last order by d.last_modified_date) acna1, 
       max(trim(d.ccna)) keep (dense_rank last order by d.last_modified_date) ccna1,
       max(trim(d.acna)) keep (dense_rank first order by d.acna) acna2, 
       max(trim(d.ccna)) keep (dense_rank first order by d.ccna) ccna2,
       max(substr(f.clli_code,1,6)) keep (dense_rank last order by f.last_modified_date) cllia,
       max(substr(f2.clli_code,1,6)) keep (dense_rank last order by f2.last_modified_date) clliz,
       max(substr(f.exchange_area_clli,1,6)) keep (dense_rank last order by f.last_modified_date) exch_cllia,
       max(substr(f2.exchange_area_clli,1,6)) keep (dense_rank last order by f2.last_modified_date) exch_clliz
from 
(
select a.fld_requestid ticket_id,
       max(substr(a.fld_siteid,1,6)) keep (dense_rank last order by a.fld_modifieddate) site_clli6,
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state,
       max(a.fld_customeraddressstate) keep (dense_rank last order by a.fld_modifieddate) rem_state,
       a.exchange_carrier_circuit_id ckt_id, 
       replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
       max(trim(a.acna)) keep (dense_rank last order by a.fld_modifieddate) acna, 
       max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
       max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
       max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
       max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
       max(round(a.h_fld_totalopentime_secs_/3600,2)) keep (dense_rank last order by a.fld_modifieddate) Total_Duration,
       max(a.fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
       max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
       max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,   
       max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
       max(a.fld_alocationaccessname2) location_name,
       max(fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) cause_cd,
       max(trim(a.fld_assignmentprofile)) keep (dense_rank first order by a.fld_modifieddate) assignmentprofile,
       max(e.location_id) keep (dense_rank last order by e.last_modified_date) location_id,
       max(e.location_id_2) keep (dense_rank last order by e.last_modified_date) location_id_2
from casdw.trouble_ticket_r a,  
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (to_char(dte_closeddatetime,'yyyymm') in ('202312')    --NEED TO CHANGE THIS EACH MONTH (CURRENT AND PREVIOUS MONTHS)
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') in ('202312')))   --NEED TO CHANGE THIS EACH MONTH (CURRENT AND PREVIOUS MONTHS) 
 and (e.type <> 'T' or type is null) 
 and e.status (+) = '6'
group by a.fld_requestid, a.exchange_carrier_circuit_id
) z,
  casdw.design_layout_report d,
  casdw.network_location f,
  casdw.network_location f2
where z.ckt_id = d.ecckt(+)
 and z.location_id = f.location_id(+)
 and z.location_id_2 = f2.location_id(+) 
 group by ticket_id, site_clli6, site_state, rem_state, ckt_id, circuit, z.acna, request_type, create_date,
       cleared_dt, closed_dt, ttr, total_duration, repair_code, reqstat, z.location_name,
       assignmentprofile, service_type_code, rate_code, cause_cd
)a, 
  trbl_found_remedy b,
  DIRECTOR_CLLI_4 dir1,
  DIRECTOR_CLLI_4 dir2,
  DIRECTOR_CLLI_4 dir3,
  DIRECTOR_CLLI_4 dir4,
  DIRECTOR_CLLI_4 dir5,
  DIRECTOR_CLLI_4 dir6,
  DIRECTOR_CLLI_4 dir7
where a.repair_code = b.trbl_found_desc (+)
 and a.site_clli6 = dir1.clli (+)
 and a.clliz = dir2.clli (+)
 and a.exch_clliz = dir3.clli (+)
 and a.cllia = dir4.clli (+)
 and a.priloc = dir5.clli (+)
 and a.actl = dir6.clli (+)
 and a.mux = dir7.clli (+)
and substr(ckt_id,7,1) <> 'U'   
and (request_type in ('Agent','Alarm','Customer','Maintenance')
  or (assignmentprofile in ('FTW TSC','CTF TSC'))) 
and substr(ckt_id,4,2) not in ('VM','EM','IP','IB','FX','YB','YG','UG','UH','RT','PL','LA','LU','XA','LA','LO','LN','LU','FD','US','CS')
and reqstat = 'Closed'
)data, 
 rvv827.carrier_list cl
where clec_id = cl.acna(+)
and assignmentprofile||repair_code not in ('FTW TSCassigningProvisioning','CTF TSCassigningProvisioning') 
and data.product in ('DS0','DS1','DS3','OCN','Ethernet')
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
			  'NKH','OCB','OVT','PHG','PUA','SGY','TVC','TVN','UHC','VLR','VPM','TFU','NVE','AZC','DSG','SHO','TZJ','BAL','NKV',
              'MTV','DSE','EPO','GBS','GBW','IZC','LKG','MOQ','NAO','OER','OVC','SXY','UVA','GIM')
)
where (disp in ('CO','FAC','CC','NTF') or disp is null)
)	
where state not in ('WA','OR','ID','MT')				 
order by 1,2,16 desc;       


