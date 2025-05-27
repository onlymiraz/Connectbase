select to_char(response_date,'MM') mon, isccode, ccna, 
         CASE WHEN CCNA IN ('FET','FWN') THEN 'LUMOS'
              WHEN CCNA IN ('BUC','BUR','CFA','AHY','ALI','ALN','AQH','ASC','ASI','AVD','AVZ','ENW','ESM','EYA','EYL','EYM','FAB','HSE',
                            'HTJ','HTX','HWV','HYH','HYS','HYT','HYV','ICG','IMR','IPX','IXC','FLS','FOC','GIE','GSX','GTT','HAL','HCV','HDC','HDE',
                            'HFL','HGA','HIP','HKS','HMA','HMD','HNI','HNJ','HOH','HOR','HPA','HPM','CTO','EAS','PHY','LGG','LHT','LNH','LNK','LVC',
                            'LVW','MAD','NCY','NJF','NTT','NVN','SSM','SUR','TDT','VNL','VOY','WCA','WCU','WIZ','WLT','TTW','UNL','PUN','RTC','SCH',
                            'AVS','CBU','CHL','CMA','GCW','GSM','GTC','ICU','IFC','PLI','PTH','TIM','TIW','TQL','TWD','TWF','TWK','XMC')
                            THEN 'LEVEL 3' --Includes TW Telecom  
              WHEN CCNA IN ('BEY','CAL','CGP','AEH','ATS','AWX','ENY','FDC','INA','JJJ','HOG','CRV','CWK','DGL','DTI','PAC','PHX','LCZ','LDW','LGT',
                            'LTL','TED','USW','UWB','UWC','UWI','VNS','TLX','QST','QWE','SEP','SML','SPA','MIV') THEN 'LUMEN TECHNOLOGIES'
              WHEN CCNA IN ('BFC','BFP','BML','BTL','CBA','CDD','CFO','ADG','ADO','AKJ','AKV','ALS','ALU','ANI','ANW','APC','API','ATE','ELE','EMI',
                            'EXF','FAA','FED','FIB','ICF','ICI','ICT','IDB','IPC','ISC','ITD','ITT','ITW','JRL','FNE','CML','CNO','COE','COK','CPQ',
                            'CUI','CYG','CYT','CYY','DGX','DNI','EGI','OTN','LCI','LDD','LDL','LDS','LET','LNT','LSI','LSY','MAI','MAL','MAP','MAS',
                            'MAW','MCG','MCI','MCJ','MCK','MCX','MCY','MEC','MFD','MFS','MFZ','MIC','MLG','MLL','MPL','MPU','MRA','MSG','MST','MTD',
                            'MTF','MTY','MUR','NAS','NCQ','NFL','NLT','NTK','NTV','NWI','NWS','NYD','SYT','TAG','TCC','TDD','TEM','TEN','TET','UST',
                            'UUN','UVR','VGM','VIN','VUS','WDC','WDM','WTL','WUA','WUI','TFB','TFY','TGR','TIQ','TMN','TNC','TNO','TNW','TOA','TOM',
                            'TOR','TRI','TRT','TSF','TSG','TTM','TUH','TVT','TXO','TYR','UEL','UNF','RCG','SAN','SBS','SBX','SLS','SNC','SNS','SNT',
                            'SNW') THEN 'VERIZON BUSINESS'
              WHEN CCNA IN ('BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','AAK','AHG','AKR','AOK','AUL','BAM','BBK','FCO','FCS','IAP','ICN','IDE','IPD',
                            'JCC','KOC','FMN','FNT','GAF','GEX','GMB','GMT','GNL','GTB','GTE','GVU','CLW','CMO','CNL','CNN','COQ','CRB','CRR','CRY',
                            'CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG','DYT','EBA','ECT','OHC','OMC','PCF','PLP','PPM','LCN','LSC','MBN',
                            'MCB','MJP','MMH','MMO','NBT','NOH','NVC','NYM','NYR','SRY','SZP','TDQ','TDU','UTI','UTS','VRZ','ULN','UNV','PTE','PTG',
                            'PTI','PTM','PUL','RMB','RMD','SOT','BAL') then 'VERIZON WIRELESS'                
              WHEN CCNA IN ('AAV','ATX','SBB','SBZ','SUV','TPM') THEN 'ATT COMMUNICATIONS'
              WHEN CCNA IN ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AUA','AUR',
                            'AUZ','AWL','AWN','AXD','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BNY','BPN','BSM','BTE','CBL','CCB','CDA','CDP','CEJ',
                            'CEO','CEU','CFN','CGH','CIF','CIV','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO','CSU','CSX','CTJ','CUO','CXA','CZB',
                            'DBY','DIC','DNC','DUT','EKC','EST','ETP','ETX','EWC','FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLN','HLU','HNC',
                            'HRN','HTN','HWC','IFP','IMP','IND','ISZ','IUW','JCT','KYR','LAA','LAC','LBH','LHR','LNZ','LSZ','MBQ','MCA','MCC','MCE',
                            'MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MKN','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MUM','MWB','MWZ','NBC','NHO',
                            'NPW','OAK','OCL','ORV','OSU','PCK','PCW','PFM','PIG','PKG','RAD','RFC','RMC','RMF','RRC','SBG','SBM','SBN','SCU','SCZ',
                            'SHI','SLL','SMC','SNP','STH','SUF','SVU','SWM','SWP','SWT','SWV','SYC','SYG','SZM','TGH','TQU','UMT','VGD','VRA','WBT',
                            'WCX','WGL','WLG','WLZ','WVO','WWC','YBG') THEN 'ATT MOBILITY'
              WHEN CCNA IN ('AEJ','AVJ','AWH','BMJ','CJG','CND','ENA','EXE','FDN','FDW','FRG','GBU','KDL','LDM','LTT','MWR','MZJ','NLG','NNN','NSC',
                            'OLP','PFT','TAD','VAU','VLO','WSJ','YOH','YVA','ALG','AMM','ARJ','CAB','CCK','CDN','CPK','DLM','DOV','FEL','IOR','LCG',
                            'LDN','LDO','LDR','LMI','LOG','LWK','NKH','OCB','OVT','PHG','PUA','SGY','TVC','TVN','UHC','VLR','VPM') THEN 'WINDSTREAM'
              WHEN CCNA IN ('GSP','GTS','ISA','LCF','LDU','LSU','NEV','SNK','SPC','STX','SUA','TNU','ULG','USP','UTC','UTL') THEN 'SPRINT'
              WHEN CCNA IN ('AEY','CXE','CXJ','DCC','DCX','EIP','GLF','GUS','IGW','LPL','MJC','NLZ','NXT','ONM','ROW','SPV','SWQ','SZC','UBQ','WEL',
                            'WOW','WSO') THEN 'SPRINT PCS'
              WHEN CCNA IN ('ABW','APT','ICJ','OPT','PSO','WCG','TZV','PWR','SJV') THEN 'TMOBILE'     
              WHEN CCNA IN ('AFY','CWV','FBL','IUT','NXO','ONO','TQW','USH') THEN 'XO COMMUNICATIONS'
              WHEN CCNA IN ('AYD','DVN','ELG','OGT','ORO','PCL') THEN 'INTEGRA'
              WHEN CCNA IN ('UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','USC','WCT') THEN 'US CELLULAR'
              WHEN CCNA IN ('HOC','UXW','CPO','NVA','LTP','DLT','BTI','NGE') THEN 'EARTHLINK'
              WHEN CCNA IN ('TFU','NVE','DSG','AZC','SHO','TZJ') THEN 'TELEPACIFIC'
              WHEN CCNA IN ('AFW','AXJ','CRZ','GRM','LRS','PYQ','TTU','UWT','VAF','VLK') THEN 'BIRCH TELECOM'
           ELSE 'OTHER' END CUSTOMER, 
       pon, status, request_date, response_date, reqtype, act, document_number, state,
       case when state in ('AL','GA','MS','TN') then 'South States'
            when state in ('IA','MN','NE') then 'Mid States'
            when state in ('AZ','NM','NV') then 'Southwest'
            when state in ('MD','VA') then 'WV'
            when state in ('KY') then 'IN'
            else state end territory,
       case WHEN STATE IN ('CT','NY','PA','AL','FL','GA','MS','NC','SC','TN') then 'Eastern'
            WHEN STATE IN ('IA','IL','IN','MI','MN','NE','WI','KY','TX','OH','WV','MD','VA') then 'Central'
       		WHEN STATE IN ('CA','AZ','NM','NV','UT') then 'Western'
            else 'UNK' end region,
       case when isccode in ('GT10','GT11') then 'CTF' else 'Legacy' end area,
       prod, NC, acna, ckt, spec 
   from (       
select isccode, ccna, pon, status, request_date, response_date, reqtype, act, document_number,
       CASE WHEN STATE IS NOT NULL THEN state 
            WHEN ISCCODE = 'SN01' THEN 'CT' ELSE NPASTATE END STATE,
       case when evc_ind ='A' then 'Ethernet-EVC'
       when evc_ind = 'B' then 'Ethernet-Combo'
       when substr(nc,1,1) in ('V') then 'Ethernet-EVC'
       when substr(nc,1,1) in ('K') then 'Ethernet-UNI'
       when substr(nc,1,2) = 'SN' then 'Ethernet-NNI'
       when substr(ckt,4,1) in ('V') then 'Ethernet-EVC'
       when substr(ckt,4,1) in ('K') then 'Ethernet-UNI'
       when substr(ckt,4,2) in ('SX') then 'Ethernet-NNI'
       else 'UNK' end prod, 
       NC, acna, ckt, spec, evc_ind, BDT_CLOSE, UNE
   from (     
select isccode, ccna, pon, status, request_date, response_date, reqtype, act, state, acna, document_number, UNE,
       CASE WHEN NC IS NOT NULL THEN NC ELSE SVC_TYPE END NC,
       case when ckt is not null then ckt else ckt2 end ckt,
       evc_ind, SPEC, substr(exchange_area_clli,5,2) npastate, BDT_CLOSE  
   FROM (     
select isccode, a.ccna, a.pon, a.status, request_date, response_date, reqtype, activity, state,
       max(sr.document_number) KEEP (DENSE_RANK FIRST ORDER BY SR.LAST_MODIFIED_DATE) document_number, 
       MAX(CIR.SERVICE_TYPE_CODE) KEEP (DENSE_RANK FIRST ORDER BY CIR.LAST_MODIFIED_DATE) SVC_TYPE,
       MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NC, 
       max(sr.acna) keep (dense_rank last order by sr.last_modified_date) acna,
       max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
       MAX(ASR.IC_CIRCUIT_REFERENCE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) ckt2,
       MAX(ASR.ACTIVITY_INDICATOR) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) ACT,
       MAX(asr.service_and_product_enhanc_cod) KEEP (dense_rank last ORDER BY asr.last_modified_date) SPEC,
       MAX(ASR.EVC_IND) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EVC_IND,
       MAX(ASR.UNBUNDLED_NETWORK_ELEMENT) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) UNE,
       MAX(ASR.NPA) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NPA,
       MAX(ASR.NXX) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NXX,
       MAX(TJW.jeopardy_reason_code) KEEP (DENSE_RANK LAST ORDER BY TJW.LAST_MODIFIED_DATE) JEOP_CODE, 
       MAX(TJW.date_closed) KEEP (DENSE_RANK LAST ORDER BY TJW.LAST_MODIFIED_DATE) BDT_CLOSE 
from (
select isccode,vfo.ccna, vfo.pon, 'Confirmed' status,  reqtype, activity, requeststate state,
min(submitteddatetime) request_date, 
min(updatedatetime) response_date
from (
--
select distinct ccna, pon from whsl_adv_hist.vfo_orderhistoryinfo_thist vfo
where orderstatus in ('Confirmed_Submitted','Confirmed_Sent')
and to_char(updatedatetime,'yyyymm') = '202310'  --CHANGE IN 2 PLACES  
and isccode <> 'FTRORD'
and ccna not in ('FLR','ZZZ','ZTK','CUS')
and substr(reqtype,1,1) in ('E','S')
) a,
  whsl_adv_hist.vfo_orderhistoryinfo_thist vfo
where a.ccna = vfo.ccna
and a.pon = vfo.pon 
and orderstatus in ('Confirmed_Submitted','Confirmed_Sent')
and isccode <> 'FTRORD'
and vfo.ccna not in ('FLR','ZZZ','ZTK','CUS')
and substr(reqtype,1,1) in ('E','S')
group by isccode, vfo.ccna, vfo.pon, reqtype, activity, requeststate
) a, 
  whsl_adv_hist.m6_serv_req_thist sr,
  whsl_adv_hist.m6_accs_svc_request_thist asr,  
  whsl_adv_hist.m6_serv_req_ckt_thist src, 
  whsl_adv_hist.m6_circuit_thist cir,
  whsl_adv_hist.m6_task_jeopardy_whymiss_thist tjw
where a.pon = sr.pon
and a.ccna = sr.ccna
and sr.document_number = asr.document_number
and sr.document_number = src.document_number (+)
and SRC.CIRCUIT_DESIGN_ID = CIR.CIRCUIT_DESIGN_ID (+)
and sr.document_number = tjw.document_number (+)
and jeopardy_reason_code (+) in ('CA07','1J')
and to_char(response_date,'yyyymm') = '202310'  --CHANGE IN 2 PLACES
group by isccode, a.ccna, a.pon, a.status, request_date, response_date, reqtype, activity, state
) b, whsl_adv_hist.m6_npa_nxx npa
where b.npa = npa.npa (+)
and b.nxx = npa.nxx (+)
and act in ('N')
))
where (UNE <> 'Y' OR UNE IS NULL)
and bdt_close is null
and (ACNA NOT IN ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',
                  'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ','XYY') OR ACNA IS NULL)
and prod in ('Ethernet-UNI','Ethernet-NNI','Ethernet-Combo')
order by response_date;