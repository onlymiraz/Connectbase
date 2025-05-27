select ticket_id, state, clec_id, customer, ckt_id, product, create_date, cleared_dt, closed_dt,                                         
       ttr, request_type, repair_code, disp, cause_cd, TROUBLE_DESC                                         
from (                                        
--                                        
select ticket_id, data2.state,                                          
       case when area is not null then area                                        
            when area is null and rs.region is not null then rs.region                                        
            else null end region,                                        
       territory, director, clec_id, customer, ckt_id, product, create_date, cleared_dt, closed_dt,                                          
       case when disp = 'NTF' then 0 else ttr end ttr,  -- Per Matt Freeman on 1/30/2017                                          
       repair_code, disp, clli_code site_clli, request_type, cause_cd,                                       
       reqstat, location_name, assignmentprofile, clli_code1, TROUBLE_DESC                                        
from (                                        
--                                        
select distinct ticket_id, clec_id, ckt_id, product, create_date, cleared_dt, closed_dt,                                         
       ttr, total_duration, repair_code, disp,                                         
       reqstat, location_name, cl.customer, assignmentprofile, request_type, TROUBLE_DESC,  cause_cd,                                      
       case when site_state is not null                                         
             and site_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then site_state                                        
            when clliz_state is not null                                         
             and clliz_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then clliz_state                                        
            when exchz_state is not null                                         
             and exchz_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then exchz_state                                        
            when cllia_state is not null                                         
             and cllia_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then cllia_state                                         
            when priloc_state is not null                                         
             and priloc_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then priloc_state                                        
            when final_state is not null                                        
             and final_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then final_state                                        
            when substr(ckt_id,1,2) in ('81','45') then 'CA'                                        
            when substr(ckt_id,1,2) in ('69','65') then 'FL'                                        
            when substr(ckt_id,1,2) in ('12','13') then 'TX'                                        
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
       mux_clli, mux_area, mux_ter, mux_dir, mux_state, clli_code, clli_code1                                                                  
from (                                        
--                                        
select distinct ticket_id,                                         
       priloc_state,                                        
       case when acna is not null then acna                                        
            when acna1 is not null then acna1                                        
            when ccna1 is not null then ccna1                                        
            when acna2 is not null then acna2                                        
            else ccna2 end CLEC_ID,                                                
       ckt_id,                                          
       case when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'                                        
            when substr(circuit,1,2) = 'R2' then 'Ethernet'                                        
            when substr(circuit,4,2) in ('L1','L2') then 'Ethernet'                                         
            when substr(service_type_code,1,2) = 'SX' then 'Ethernet'                                        
            when substr(circuit,3,1) in ('K','V') then 'Ethernet'                                        
            else ' ' end product,                                        
       create_date, Cleared_Dt,                                         
       case when Closed_Dt is not null then Closed_dt                                        
            else Cleared_dt end Closed_Dt,                                        
       Total_Duration, TTR, a1.repair_code, b.disp, reqstat, clli_code1, request_type, TROUBLE_DESC, a1.cause_cd,                                       
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
--                                        
select ticket_id, site_clli6, site_state, ckt_id, circuit, a.acna, request_type, create_date,                                        
       cleared_dt, closed_dt, ttr, total_duration, repair_code, reqstat, a.location_name,                                        
       assignmentprofile, service_type_code, rate_code, TROUBLE_DESC, cause_cd,                                        
       max(trim(d.acna)) keep (dense_rank last order by d.last_modified_date) acna1,                                         
       max(trim(d.ccna)) keep (dense_rank last order by d.last_modified_date) ccna1,                  
       max(trim(d.acna)) keep (dense_rank first order by d.acna) acna2,                 
       max(trim(d.ccna)) keep (dense_rank first order by d.ccna) ccna2,                 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc_state,                                        
       max(substr(d.primary_location,1,6)) keep (dense_rank last order by d.last_modified_date) priloc,                                        
       max(substr(d.access_cust_terminal_location,1,6)) keep (dense_rank last order by d.last_modified_date) actl,                                        
       max(substr(d.mux_location,1,6)) keep (dense_rank last order by d.last_modified_date) mux,                                        
       max(substr(f.clli_code,1,6)) keep (dense_rank last order by f.last_modified_date) cllia,                                        
       max(substr(f2.clli_code,1,6)) keep (dense_rank last order by f2.last_modified_date) clliz,                
       max(f2.clli_code) keep (dense_rank last order by f2.last_modified_date) clli_code1,                                        
       max(substr(f.exchange_area_clli,1,6)) keep (dense_rank last order by f.last_modified_date) exch_cllia,                
       max(substr(f2.exchange_area_clli,1,6)) keep (dense_rank last order by f2.last_modified_date) exch_clliz                
 from                                              
(                                        
--                                        
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
       max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code, 
       max(fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) cause_cd,                                       
       max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,                                        
       max(a.fld_alocationaccessname2) location_name,                                        
       max(trim(a.fld_assignmentprofile)) keep (dense_rank first order by a.fld_modifieddate) assignmentprofile,                                        
       max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code,                                         
       max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,               
       max(e.location_id) keep (dense_rank last order by e.last_modified_date) location_id,                                        
       max(e.location_id_2) keep (dense_rank last order by e.last_modified_date) location_id_2,                                        
       REPLACE(REPLACE(A.FLD_DESCRIPTIONOFSYMPTON,CHR(10),''),CHR(13),'') TROUBLE_DESC                                        
from casdw.trouble_ticket_r a,                                        
     casdw.circuit e                                        
where a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)                                         
 and a.fld_troublereportstate = 'closed'                                        
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')                                        
 and (e.type <> 'T' or type is null)                                         
 and e.status (+) = '6'                                        
 and (to_char(dte_closeddatetime,'yyyymm') = '202310'    --NEED TO CHANGE THIS EACH MONTH (CURRENT AND PREVIOUS MONTHS)                                        
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') = '202310'))   --NEED TO CHANGE THIS EACH MONTH (CURRENT AND PREVIOUS MONTHS)                                         
group by a.fld_requestid, a.exchange_carrier_circuit_id, A.FLD_DESCRIPTIONOFSYMPTON                                      
--                                        
)a,                                        
 casdw.design_layout_report d,                                        
 casdw.network_location f,                                        
 casdw.network_location f2                                        
 where a.ckt_id = d.ecckt(+)                                        
 and a.location_id = f.location_id(+)                                        
 and a.location_id_2 = f2.location_id(+)                                        
 and substr(ckt_id,7,1) <> 'U'                                           
 --and request_type in ('Agent','Alarm','Customer','Maintenance')                                         
 and substr(ckt_id,4,2) not in ('VM','EM','IP','IB','FX','YB','YG','UG','UH','RT','PL','LA','LU','XA','LA','LO','LN','LU','FD','US','CS')                                        
 and reqstat = 'Closed'                                         
 group by ticket_id, site_clli6, site_state, ckt_id, circuit, a.acna, request_type, create_date,                                        
          cleared_dt, closed_dt, ttr, total_duration, repair_code, reqstat, a.location_name,                                        
          assignmentprofile, service_type_code, rate_code, TROUBLE_DESC, cause_cd                                        
--                                        
)a1,                                        
 trbl_found_remedy b,                                        
 DIRECTOR_CLLI_4 dir1,                                        
 DIRECTOR_CLLI_4 dir2,                                        
 DIRECTOR_CLLI_4 dir3,                                        
 DIRECTOR_CLLI_4 dir4,                                        
 DIRECTOR_CLLI_4 dir5,                                        
 DIRECTOR_CLLI_4 dir6,                                        
 DIRECTOR_CLLI_4 dir7                                        
where a1.repair_code = b.trbl_found_desc (+)                                        
 and a1.site_clli6 = dir1.clli (+)                                        
 and a1.clliz = dir2.clli (+)                                        
 and a1.exch_clliz = dir3.clli (+)                                        
 and a1.cllia = dir4.clli (+)                                        
 and a1.priloc = dir5.clli (+)                                        
 and a1.actl = dir6.clli (+)                                        
 and a1.mux = dir7.clli (+)                                         
--                                        
)data,                                         
 rvv827.carrier_list cl                                        
where clec_id = cl.acna(+)                                         
and data.product in ('Ethernet')                                        
and (clec_id not in ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',                                        
                     'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ','GOV','FTR',                                        
                     'AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',                                        
                     'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWS','AWL','AWN','AZE','BAC',    
                     'BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','CBL','CCB','CDA','CEL',   
                     'CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',  
                     'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','ETP','EST','ETX',   
                     'FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','HWC',   
                     'IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',      
                     'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ',    
                     'MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV',    
                     'OSU','PCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN','SCU',    
                     'SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM',     
                     'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO',      
                     'ABW','APT','ICJ','OPT','PSO','WCG','TZV','PWR','SJV',                                        
                     'AEY','IGW','GLF','GUS','CXE','CXJ','DCC','DCX','EIP','ONM','LPL','MJC',                                        
                     'NLZ','NXT','SWQ','SZC','WEL','WOW','WSO','UBQ','ROW','SPV',                                        
                     'BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','AAK','AHG','AKR','AOK','AUL',                                        
                     'BAM','BBK','FCO','FCS','IAP','ICN','IDE','IPD','JCC','KOC','FMN','FNT',                                        
                     'GAF','GEX','GMB','GMT','GNL','GTB','GTE','GVU','CLW','CMO','CNL','CNN',     
                     'COQ','CRB','CRR','CRY','CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG',     
                     'DYT','EBA','ECT','OHC','OMC','PCF','PLP','PPM','LCN','LSC','LTT','MBN',     
                     'MCB','MJP','MMH','MMO','NBT','NOH','NVC','NYM','NYR','SRY','SZP','TDQ',     
                     'TDU','UTI','UTS','VRZ','ULN','UNV','PTE','PTG','PTI','PTM','PUL','RMB',    
                     'RMD','SOT','BAL',     
                     'UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','USC','WCT' ) and clec_id is not null)                                        
--                                        
)data2,                                         
 rvv827.region_state rs                                        
where data2.state = rs.state (+)                                        
--                                        
)                                        
where state not in ('WA','OR','ID','MT')                                          
order by 9,1;                                                 
