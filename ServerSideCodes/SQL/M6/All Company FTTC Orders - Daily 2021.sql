SELECT *
FROM (
SELECT CASE WHEN ACNA IN ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWS','AWL','AWN','AZE','BAC',
                   'BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','CBL','CCB','CDA','CEL','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
                   'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','HWC',
                   'IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ',
                   'MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV','OSU','PCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN','SCU',
                   'SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO') THEN 'ATT MOBILITY'
     WHEN ACNA IN ('ABW','APT','ICJ','OPT','PSO','WCG','TZV','PWR','SJV') THEN 'TMOBILE'  
     WHEN ACNA IN ('AEY','IGW','GLF','GUS','CXE','CXJ','DCC','DCX','EIP','ONM','LPL','MJC','NLZ','NXT','SWQ','SZC','WEL','WOW','WSO','UBQ','ROW','SPV') THEN 'SPRINT PCS'  
     WHEN ACNA IN ('BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','AAK','AHG','AKR','AOK','AUL','BAM','BBK','FCO','FCS','IAP','ICN','IDE','IPD','JCC','KOC','FMN','FNT',
                   'GAF','GEX','GMB','GMT','GNL','GTB','GTE','GVU','CLW','CMO','CNL','CNN','COQ','CRB','CRR','CRY','CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG',
                   'DYT','EBA','ECT','OHC','OMC','PCF','PLP','PPM','LCN','LSC','LTT','MBN','MCB','MJP','MMH','MMO','NBT','NOH','NVC','NYM','NYR','SRY','SZP','TDQ',
                   'TDU','UTI','UTS','VRZ','ULN','UNV','PTE','PTG','PTI','PTM','PUL','RMB','RMD','SOT') THEN 'VERIZON WIRELESS'  
     WHEN ACNA IN ('UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','USC','WCT') THEN 'US CELLULAR'  
     WHEN ACNA IN ('EIW') THEN 'ION'
     WHEN ACNA IN ('MFQ') THEN 'METROPCS'
     WHEN ACNA IN ('CFQ') THEN 'NTELOS'
     WHEN ACNA IN ('AZY') THEN 'COMMNET WIRELESS'
     WHEN ACNA IN ('ATC','GMW','HPL','NTS') THEN 'NTS COMMUNICATIONS'
     END CARRIER_NAME,
ACNA, DOCNO, PON, PROJ, STATE, ICSC, ACT_IND, 
SUBSTR(USID_PRELIM,1,LEAST(DECODE(INSTR(USID_PRELIM,'E'),0,99,INSTR(USID_PRELIM,'E')),
          DECODE(INSTR(USID_PRELIM,'V'),0,99,INSTR(USID_PRELIM,'V')),
          DECODE(INSTR(USID_PRELIM,'O'),0,99,INSTR(USID_PRELIM,'O')),
          DECODE(INSTR(USID_PRELIM,'C'),0,99,INSTR(USID_PRELIM,'C')),
          DECODE(INSTR(USID_PRELIM,'D'),0,99,INSTR(USID_PRELIM,'D')),
          DECODE(INSTR(USID_PRELIM,'R'),0,99,INSTR(USID_PRELIM,'R')),
          DECODE(INSTR(USID_PRELIM,'-'),0,99,INSTR(USID_PRELIM,'-')))-1) USID_FA,     
CKR, CKT, D_REC, DD, DDD, TASK_TYPE, TASK_STATUS, TASK_REVISED_COMP_DT, TASK_ACTUAL_COMP_DT, 
TASK_SCHED_COMP_DT, WORK_QUEUE,    
CASE WHEN (SUBSTR(NC,1,1) = 'K' OR SUBSTR(CKT,4,1) = 'K') THEN 'UNI'
            WHEN SUBSTR(CKT,4,1) = 'V' THEN 'EVC'
            WHEN SUBSTR(PROJ,1,10) = 'ATTMOB-EVC' THEN 'EVC'
            WHEN SUBSTR(PROJ,1,10) = 'ATTMOB-MLT' THEN 'EVC'
            WHEN SUBSTR(PROJ,1,10) = 'ATTMOB-OAM' THEN 'EVC'
            WHEN SUBSTR(PROJ,1,10) = 'ATTMOB-TLS' THEN 'UNI'
            WHEN SUBSTR(PROJ,1,6) = 'MPAEVC' THEN 'EVC'
            WHEN PROJ LIKE '%VLAN%' THEN 'EVC'
            WHEN PROJ LIKE '%-MTS%' THEN 'EVC'
            WHEN PROJ LIKE '%BDW%' THEN 'EVC'
            WHEN PROJ LIKE '%EVC%' THEN 'EVC'
            WHEN PROJ LIKE '%TLS%' THEN 'UNI'
            WHEN PROJ LIKE '%UNI%' THEN 'UNI'
            WHEN PROJ LIKE '%TSP%' THEN 'UNI'
            when substr(ckt,4,2) = 'LX' and substr(PNUM,1,3) = 'DKF' then 'Dark Fiber'
            ELSE NULL END PRODUCT,               
PNUM, CFA
FROM (             
SELECT TRUNC(D_REC) D_REC, PROJ, CKR, DOCUMENT_NUMBER DOCNO, PON, 
       SUBSTR(PON,LEAST(DECODE(INSTR(PON,'0'),0,99,INSTR(PON,'0')),
          DECODE(INSTR(PON,'1'),0,99,INSTR(PON,'1')),
          DECODE(INSTR(PON,'2'),0,99,INSTR(PON,'2')),
          DECODE(INSTR(PON,'3'),0,99,INSTR(PON,'3')),
          DECODE(INSTR(PON,'4'),0,99,INSTR(PON,'4')),
          DECODE(INSTR(PON,'5'),0,99,INSTR(PON,'5')),
          DECODE(INSTR(PON,'6'),0,99,INSTR(PON,'6')),
          DECODE(INSTR(PON,'7'),0,99,INSTR(PON,'7')),
          DECODE(INSTR(PON,'8'),0,99,INSTR(PON,'8')),
          DECODE(INSTR(PON,'9'),0,99,INSTR(PON,'9'))),99) USID_PRELIM,
      case when CKT is not null then CKT 
           when CKT2 is not null then CKT2
           else circkt end CKT, 
      dd, DDD, TASK_TYPE, TASK_STATUS, TASK_REVISED_COMP_DT, TASK_ACTUAL_COMP_DT, 
       TASK_SCHED_COMP_DT,  ACT_IND,  WORK_QUEUE, ICSC,
       CASE WHEN npa.state IS NOT NULL THEN npa.state
            WHEN clliz IS NOT NULL THEN SUBSTR(clliz,5,2)
            WHEN ICSC = 'FV01' THEN 'WV'
            WHEN ICSC = 'SN01' then 'CT'
            WHEN ICSC = 'RT01' THEN 'NY'
            WHEN cllia IS NOT NULL THEN SUBSTR(cllia,5,2)
            WHEN SUBSTR(PROJ,-2) IN ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN') THEN SUBSTR(PROJ,-2)
            ELSE NULL END state,
       ACNA, NC, PNUM, CFA
FROM
(
SELECT MAX(SR.PON) KEEP (dense_rank last ORDER BY sr.last_modified_date) PON,
  SR.DOCUMENT_NUMBER,
  MAX(SUBSTR(NL1.CLLI_CODE,5,2)) KEEP (dense_rank last ORDER BY nl1.last_modified_date) CLLIA,
  MAX(SUBSTR(NL2.CLLI_CODE,5,2)) KEEP (dense_rank last ORDER BY nl2.last_modified_date) CLLIZ,    
  MAX(SR.ACTIVITY_IND) KEEP (dense_rank last ORDER BY sr.last_modified_date) ACT_IND,
  MAX(SR.SUPPLEMENT_TYPE) KEEP (dense_rank last ORDER BY sr.last_modified_date) SUPP_TYPE,
  MAX(SR.FIRST_ECCKT_ID) KEEP (dense_rank last ORDER BY sr.last_modified_date) CKT,
  max(asr.ic_circuit_reference) keep (dense_rank last order by asr.last_modified_date) ckt2,
  max(CIR.EXCHANGE_CARRIER_CIRCUIT_ID) keep (dense_rank last order by cir.last_modified_date) CIRCKT,
  MAX(asr.date_time_sent) KEEP (dense_rank last ORDER BY asr.last_modified_date) D_REC,
  MAX(asr.desired_due_date) KEEP (dense_rank last ORDER BY asr.last_modified_date) DD, 
  MAX(AUD.crdd) KEEP (dense_rank last ORDER BY aud.last_modified_date) DDD,
  TSK.ACTUAL_COMPLETION_DATE TASK_ACTUAL_COMP_DT,
  TSK.SCHEDULED_COMPLETION_DATE-4/24 TASK_SCHED_COMP_DT,
  TSK.REVISED_COMPLETION_DATE-4/24 TASK_REVISED_COMP_DT,
  TSK.WORK_QUEUE_ID WORK_QUEUE,
  MAX(ASR.ACCESS_PROVIDER_SERV_CTR_CODE) KEEP (dense_rank last ORDER BY asr.last_modified_date) ICSC,
  MAX(REPLACE(SR.PROJECT_IDENTIFICATION,' ')) KEEP (dense_rank last ORDER BY sr.last_modified_date) PROJ,
  MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) KEEP (dense_rank last ORDER BY asr.last_modified_date) NC,
  MAX(SR.ACNA) KEEP (dense_rank last ORDER BY sr.last_modified_date) ACNA,
  MAX(asr.ckr) KEEP (dense_rank last ORDER BY asr.last_modified_date) ckr,
  max(asr.connecting_facility_assignment) keep (dense_rank last order by asr.last_modified_date) CFA, 
  tsk.task_type, tsk.task_status,
  MAX(npa) KEEP (dense_rank last ORDER BY asr.last_modified_date) npa,
  MAX(nxx) KEEP (dense_rank last ORDER BY asr.last_modified_date) nxx,
  MAX(ASR.promotion_nbr) keep (dense_rank last order by asr.last_modified_date) pnum
--
FROM casdw.SERV_REQ SR, 
     casdw.ACCESS_SERVICE_REQUEST ASR, 
     casdw.NETWORK_LOCATION NL1,
     casdw.NETWORK_LOCATION NL2,
     casdw.CIRCUIT CIR,
     casdw.DESIGN_LAYOUT_REPORT DLR, 
     casdw.TASK TSK,
     casdw.TASK DD,
     CASDW.ASR_USER_DATA AUD
--
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = DD.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = DLR.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)
AND DLR.CIRCUIT_DESIGN_ID = CIR.CIRCUIT_DESIGN_ID (+)
AND CIR.LOCATION_ID = NL1.LOCATION_ID (+)
AND CIR.LOCATION_ID_2 = NL2.LOCATION_ID (+)
AND SR.TYPE_OF_SR IN ('ASR')
AND SR.REQUEST_TYPE IN ('S','E')
AND DD.task_type(+) = 'DD'
AND dd.actual_completion_date IS NULL
AND TSK.TASK_STATUS(+) = 'Ready'
and to_char(asr.date_time_sent,'YYYY') > '2020'
--AND TO_CHAR(asr.desired_due_date,'yyyy') > '2012'
AND SR.ACNA in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',            -- ATT MOBILITY  
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
                'ABW','APT','ICJ','OPT','PSO','WCG','TZV','PWR','SJV',                         --T-MOBILE  
                'AEY','IGW','GLF','GUS','CXE','CXJ','DCC','DCX','EIP','ONM','LPL','MJC',       --SPRINT PCS  
                'NLZ','NXT','SWQ','SZC','WEL','WOW','WSO','UBQ','ROW','SPV',
                'BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','AAK','AHG','AKR','AOK','AUL',       --VERIZON WIRELESS  
                'BAM','BBK','FCO','FCS','IAP','ICN','IDE','IPD','JCC','KOC','FMN','FNT',
                'GAF','GEX','GMB','GMT','GNL','GTB','GTE','GVU','CLW','CMO','CNL','CNN',
                'COQ','CRB','CRR','CRY','CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG',
                'DYT','EBA','ECT','OHC','OMC','PCF','PLP','PPM','LCN','LSC','LTT','MBN',
                'MCB','MJP','MMH','MMO','NBT','NOH','NVC','NYM','NYR','SRY','SZP','TDQ',
                'TDU','UTI','UTS','VRZ','ULN','UNV','PTE','PTG','PTI','PTM','PUL','RMB',
                'RMD','SOT',
                'UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','USC','WCT',  --US CELLULAR  
                'EIW',                                                                            --ION  
                'MFQ','MQS',                                                                            --METROPCS  
                'CFQ',                                                                            --NTELOS  
                'AZY',                                                                            --COMMNET WIRELESS  
                'ATC','GMW','HPL','NTS')                                                        --NTS COMMUNICATIONS  
AND SR.DOCUMENT_NUMBER NOT IN ('1758819','1978476','2071936','2241586','2288749','2288745','2373626','2489192','2498320','2502548'
)   
--
GROUP BY SR.DOCUMENT_NUMBER,tsk.task_type, tsk.task_status, TSK.ACTUAL_COMPLETION_DATE, 
  TSK.SCHEDULED_COMPLETION_DATE, TSK.REVISED_COMPLETION_DATE, TSK.WORK_QUEUE_ID
) data, rvv827.npanxx npa
--
WHERE data.NPA||data.NXX = NPA.NPANXX (+)
AND (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)
))
WHERE product in ('EVC','UNI','Dark Fiber')
and (state not in ('WA','OR','MT','ID') or state is null)
ORDER BY 21, 13;