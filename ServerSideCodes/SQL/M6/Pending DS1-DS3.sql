select docno, pon, act, acna, carrier, circuit, product, project, icsc, cfa, 
       address, city, state, 
       case WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
            WHEN STATE IN ('NY','PA','CT','OH','WV','MD') THEN 'EAST'
            WHEN STATE IN ('IN','KY','AL','GA','MS','TN') THEN 'MID-SOUTH'
            WHEN STATE IN ('ID','MT','IL','MN','IA','NE','UT') THEN 'NATIONAL'
            WHEN STATE IN ('AZ','NV','NM','TX') THEN 'SOUTH'
            WHEN STATE IN ('FL','NC','SC') THEN 'SOUTHEAST'
	  		WHEN STATE IN ('CA','OR','WA') THEN 'WEST'
	  	    ELSE null END REGION,
       date_rcvd, dd, crdd, task_at_ready, qty,
       case when carrier = 'ATT MOBILITY' and act = 'N' and (substr(project,3,2) in ('AM') 
                 or project like '%UMTS%') then 'ATT UMTS'
            when carrier = 'ATT MOBILITY' and map <> 'AMN' then 'ATT NON-UMTS'
            when project = 'MLPPP' then 'T-MOBILE MLPPP'
            when project in ('AUATTCVSTAR121BD','AUATTCVSTGTRPO1BD') then 'ATT CVSTAR'
            when project = 'AUATTPNCT12016BD' then 'ATT PNC'
            else null end report 
from (
select docno, pon, act, acna,
       case WHEN ACNA IN ('FET','FWN') THEN 'LUMOS'
              WHEN ACNA IN ('BUC','BUR','CFA','AHY','ALI','ALN','AQH','ASC','ASI','AVD','AVZ','ENW','ESM','EYA','EYL','EYM','FAB','HSE',
                                  'HTJ','HTX','HWV','HYH','HYS','HYT','HYV','ICG','IMR','IPX','IXC','FLS','FOC','GIE','GSX','GTT','HAL','HCV','HDC','HDE',
                            'HFL','HGA','HIP','HKS','HMA','HMD','HNI','HNJ','HOH','HOR','HPA','HPM','CTO','EAS','PHY','LGG','LHT','LNH','LNK','LVC',
                            'LVW','MAD','NCY','NJF','NTT','NVN','SSM','SUR','TDT','VNL','VOY','WCA','WCU','WIZ','WLT','TTW','UNL','PUN','RTC','SCH')
                            THEN 'LEVEL 3'
              WHEN ACNA IN ('BEY','CAL','CGP','AEH','ATS','AWX','ENY','FDC','INA','JJJ','HOG','CRV','CWK','DGL','DTI','PAC','PHX','LCZ','LDW','LGT',
                                  'LTL','TED','USW','UWB','UWC','UWI','VNS','TLX','QST','QWE','SEP','SML','SPA','MIV') THEN 'CENTURYLINK'
              WHEN ACNA IN ('BFC','BFP','BML','BTL','CBA','CDD','CFO','ADG','ADO','AKJ','AKV','ALS','ALU','ANI','ANW','APC','API','ATE','ELE','EMI',
                            'EXF','FAA','FED','FIB','ICF','ICI','ICT','IDB','IPC','ISC','ITD','ITT','ITW','JRL','FNE','CML','CNO','COE','COK','CPQ',
                            'CUI','CYG','CYT','CYY','DGX','DNI','EGI','OTN','LCI','LDD','LDL','LDS','LET','LNT','LSI','LSY','MAI','MAL','MAP','MAS',
                            'MAW','MCG','MCI','MCJ','MCK','MCX','MCY','MEC','MFD','MFS','MFZ','MIC','MLG','MLL','MPL','MPU','MRA','MSG','MST','MTD',
                            'MTF','MTY','MUR','NAS','NCQ','NFL','NLT','NTK','NTV','NWI','NWS','NYD','SYT','TAG','TCC','TDD','TEM','TEN','TET','UST',
                            'UUN','UVR','VGM','VIN','VUS','WDC','WDM','WTL','WUA','WUI','TFB','TFY','TGR','TIQ','TMN','TNC','TNO','TNW','TOA','TOM',
                            'TOR','TRI','TRT','TSF','TSG','TTM','TUH','TVT','TXO','TYR','UEL','UNF','RCG','SAN','SBS','SBX','SLS','SNC','SNS','SNT',
                            'SNW') THEN 'VERIZON BUSINESS'
              WHEN ACNA IN ('BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','AAK','AHG','AKR','AOK','AUL','BAM','BBK','FCO','FCS','IAP','ICN','IDE','IPD',
                            'JCC','KOC','FMN','FNT','GAF','GEX','GMB','GMT','GNL','GTB','GTE','GVU','CLW','CMO','CNL','CNN','COQ','CRB','CRR','CRY',
                            'CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG','DYT','EBA','ECT','OHC','OMC','PCF','PLP','PPM','LCN','LSC','MBN',
                              'MCB','MJP','MMH','MMO','NBT','NOH','NVC','NYM','NYR','SRY','SZP','TDQ','TDU','UTI','UTS','VRZ','ULN','UNV','PTE','PTG',
                            'PTI','PTM','PUL','RMB','RMD','SOT') then 'VERIZON WIRELESS'                
              WHEN ACNA IN ('AAV','ATX','SBB','SBZ','SUV','TPM') THEN 'ATT COMMUNICATIONS'
              WHEN ACNA IN ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AUA','AUR',
                                  'AUZ','AWL','AWN','AXD','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BNY','BPN','BSM','BTE','CBL','CCB','CDA','CDP','CEJ',
                               'CEO','CEU','CFN','CGH','CIF','CIV','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO','CSU','CSX','CTJ','CUO','CXA','CZB',
                            'DBY','DIC','DNC','DUT','EKC','EST','ETP','ETX','EWC','FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLN','HLU','HNC',
                            'HRN','HTN','HWC','IFP','IMP','IND','ISZ','IUW','JCT','KYR','LAA','LAC','LBH','LHR','LNZ','LSZ','MBQ','MCA','MCC','MCE',
                            'MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MKN','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MUM','MWB','MWZ','NBC','NHO',
                            'NPW','OAK','OCL','ORV','OSU','PCK','PCW','PFM','PIG','PKG','RAD','RFC','RMC','RMF','RRC','SBG','SBM','SBN','SCU','SCZ',
                            'SHI','SLL','SMC','SNP','STH','SUF','SVU','SWM','SWP','SWT','SWV','SYC','SYG','SZM','TGH','TQU','UMT','VGD','VRA','WBT',
                            'WCX','WGL','WLG','WLZ','WVO','WWC','YBG') THEN 'ATT MOBILITY'
              WHEN ACNA IN ('AEJ','AVJ','AWH','BMJ','CJG','CND','ENA','EXE','FDN','FDW','FRG','GBU','KDL','LDM','LTT','MWR','MZJ','NLG','NNN','NSC',
                                 'OLP','PFT','TAD','VAU','VLO','WSJ','YOH','YVA','ALG','AMM','ARJ','CAB','CCK','CDN','CPK','DLM','DOV','FEL','IOR','LCG',
                            'LDN','LDO','LDR','LMI','LOG','LWK','NKH','OCB','OVT','PHG','PUA','SGY','TVC','TVN','UHC','VLR','VPM') THEN 'WINDSTREAM'
              WHEN ACNA IN ('GSP','GTS','ISA','LCF','LDU','LSU','NEV','SNK','SPC','STX','SUA','TNU','ULG','USP','UTC','UTL') THEN 'SPRINT'
              WHEN ACNA IN ('AEY','CXE','CXJ','DCC','DCX','EIP','GLF','GUS','IGW','LPL','MJC','NLZ','NXT','ONM','ROW','SPV','SWQ','SZC','UBQ','WEL',
                                  'WOW','WSO') THEN 'SPRINT PCS'
              WHEN ACNA IN ('ABW','APT','ICJ','OPT','PSO','WCG','TZV','PWR','SJV') THEN 'TMOBILE'                
              WHEN ACNA IN ('AVS','CBU','CHL','CMA','GCW','GSM','GTC','ICU','IFC','PLI','PTH','TIM','TIW','TQL','TWD','TWF','TWK','XMC')
                            THEN 'TW TELECOM'    
              WHEN ACNA IN ('AFY','CWV','FBL','IUT','NXO','ONO','TQW','USH') THEN 'XO COMMUNICATIONS'
              WHEN ACNA IN ('AYD','DVN','ELG','OGT','ORO','PCL') THEN 'INTEGRA'
              WHEN ACNA IN ('UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','USC','WCT') THEN 'US CELLULAR'
              WHEN ACNA IN ('HOC','UXW','CPO','NVA','LTP','DLT','BTI','NGE') THEN 'EARTHLINK'
              WHEN ACNA IN ('TFU','NVE','DSG','AZC','SHO','TZJ') THEN 'TELEPACIFIC'
              when acna in ('RVF') then 'US SIGNAL'
              when acna in ('GIM') then 'GRANITE'
              when acna in ('OVC') then 'COVAD'
          else ACNA_NAME end carrier,
       circuit,
       case when nc = 'HC' then 'DS1'
            when nc = 'HF' then 'DS3'
            else null end product,
       project,
       icsc, cfa, qty,
       address, city, 
       case when salistate is not null then salistate
            when npastate is not null then npastate
            when icsc = 'SN01' then 'CT'
            when icsc = 'RT01' then 'NY'
            else null end state,
       date_rcvd, dd, crdd,
       task_at_ready,
       SUBSTR(PROJECT,3,2)||act map
 from (     
SELECT sr.document_number docno,
       asr.access_provider_serv_ctr_code ICSC, 
       sr.acna,
       sr.acna_name,
       asr.activity_indicator AS act, 
       sr.pon,
       c.exchange_carrier_circuit_id CIRCUIT,
       asr.project_identification PROJECT,
       SANO||' '||SASD||' '||SASN||' '||SATH ADDRESS, 
       SALI.CITY,
       substr(SALI.state,1,2) salistate,  
       asr.network_channel_service_code NC,
       TO_DATE (asr.date_received) DATE_RCVD,
       asr.desired_due_date  DD,
       asr.connecting_facility_assignment CFA,  
       aud.CRDD,
       asr.quantity_first qty,
       asr.evc_ind,
       asr.npa, asr.nxx,
       substr(npa.exchange_area_clli,5,2) npastate,
       t2.task_type TASK_AT_READY        
  FROM task t, 
       access_service_request asr,
       serv_req sr,
       circuit c,
       asr_user_data aud,
       data_ext.asr_sali sali,
       npa_nxx npa,
       task t2
 WHERE sr.document_number = asr.document_number
   and sr.document_number = aud.document_number
   and sr.first_ecckt_id = c.exchange_carrier_circuit_id (+)
   AND sr.document_number = t.document_number
   and sr.document_number = sali.document_number (+)
   AND ASR.NPA = NPA.NPA (+)
   and asr.nxx = npa.nxx (+)
   AND sr.document_number = t2.document_number (+)
   AND T.ACTUAL_COMPLETION_DATE IS NULL
   AND T2.TASK_STATUS(+) = 'Ready'
   AND (sr.supplement_type <> 1 OR sr.supplement_type IS NULL)            
   AND t.task_type = 'DD'
   and asr.order_type = 'ASR'
   --and sr.document_number = '2489282'
   and asr.network_channel_service_code in ('HC','HF')
   and asr.activity_indicator in ('N','C','T','M','R')
   and sr.acna not in ('FLR','ZTK','CUS','ZZZ','SNE','XYY','ZWV')
   ))
   order by dd, docno;
   
   
  
