select DISTINCT CARRIER_NAME, PON, SWITCH, TYPE, PORT, USID_FA_PON, EVC_EVCCKR, DOCNO, ACNA, ACT_IND, CKT,
       UNI, MTSO, RUID_SWITCH, D_REC, DD, DDD, COMP_DT, STATUS, STATE, REGION, ICSC, PRODUCT,
       PROJ, CKR, BAN, ALOC, ZLOC, CUST_EDGE_VLAN, BANDWIDTH, EVC_MEET_POINT_ID, PNUM, CFA, 
       SUM(MRC) MRC
from (
select distinct CARRIER_NAME, 
        PON, null SWITCH, null TYPE, null PORT,
        SUBSTR(USID_PRELIM,1,LEAST(DECODE(INSTR(USID_PRELIM,'E'),0,99,INSTR(USID_PRELIM,'E')),
          DECODE(INSTR(USID_PRELIM,'V'),0,99,INSTR(USID_PRELIM,'V')),
          DECODE(INSTR(USID_PRELIM,'O'),0,99,INSTR(USID_PRELIM,'O')),
          DECODE(INSTR(USID_PRELIM,'C'),0,99,INSTR(USID_PRELIM,'C')),
          DECODE(INSTR(USID_PRELIM,'D'),0,99,INSTR(USID_PRELIM,'D')),
          DECODE(INSTR(USID_PRELIM,'R'),0,99,INSTR(USID_PRELIM,'R')),
          DECODE(INSTR(USID_PRELIM,'-'),0,99,INSTR(USID_PRELIM,'-')))-1) USID_FA_PON,
     REPLACE(EVC_EVCCKR,' ','') EVC_EVCCKR, DOCNO, ACNA, ACT_IND, CKT, 
     CASE WHEN (SUBSTR(LTRIM(RUID01),4,2) != 'KG' OR SUBSTR(LTRIM(RUID02),4,2) = 'KG') THEN RUID01 ELSE RUID02 END UNI, 
     CASE WHEN (SUBSTR(LTRIM(RUID01),4,2) != 'KG' OR SUBSTR(LTRIM(RUID02),4,2) = 'KG') THEN RUID02 ELSE RUID01 END MTSO, 
     CASE WHEN ((RUID01 IS NULL AND RUID02 IS NULL) OR (SUBSTR(LTRIM(RUID01),4,2) != 'KG' OR SUBSTR(LTRIM(RUID02),4,2) = 'KG')) 
      THEN null ELSE 'RUIDs switched' END RUID_SWITCH, 
      D_REC, DD, DDD, COMP_DT,
      CASE WHEN COMP_DT IS NOT NULL THEN 'Completed'
            ELSE 'Pending' END STATUS,
       STATE, 
       CASE WHEN STATE IN ('NY','PA','CT') THEN 'Operating Area 1'
            WHEN STATE IN ('MI','OH','WV') THEN 'Operating Area 2'
            WHEN STATE IN ('AL','FL','GA','MS','NC','SC','TN') THEN 'Operating Area 3'
            WHEN STATE IN ('IA','IL','IN','MN','NE','WI','KY','MO') THEN 'Operating Area 4'
            WHEN STATE IN ('AZ','NV','NM','TX','UT') THEN 'Operating Area 5'
            WHEN STATE IN ('ID','MT','OR','WA') THEN 'Operating Area 6'
            WHEN STATE IN ('CA') THEN 'Operating Area 7'
            ELSE 'Unknown' END REGION, 
       ICSC, 
       CASE WHEN SUBSTR(NC,1,2) in ('SN') then 'NNI' 
            WHEN SUBSTR(NC,1,1) in ('K') AND ACTL IS NOT NULL AND SPEC <> 'GGAMAN' THEN 'NNI'
            WHEN (SUBSTR(NC,1,1) = 'K' OR SUBSTR(CKT,4,1) = 'K') THEN 'UNI'
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
       PROJ, CKR, BAN, ALOC, ZLOC, CUST_EDGE_VLAN, BANDWIDTH, EVC_MEET_POINT_ID, PNUM, CFA, MRC
FROM (
SELECT PON, DOCUMENT_NUMBER DOCNO, ACNA, ACT_IND, 
       case when CKT is not null then CKT 
            when CKT2 is not null then CKT2
            when circkt is not null then circkt
            else evc end ckt, 
       trunc(D_REC) D_REC, DD, DDD, 
       CASE when dd_comp is null and accept_dt > d_rec then Accept_dt
            when Accept_dt is null then dd_comp
            when Accept_dt <= dd_comp and accept_dt > d_rec then Accept_dt 
            else dd_comp end Comp_Dt, 
       ICSC, PNUM, CFA, 
       CASE WHEN CLLIZ IS NOT NULL THEN CLLIZ
            WHEN ICSC = 'SN01' then 'CT'
            WHEN ICSC = 'RT01' then 'NY'
            WHEN ICSC = 'FV01' then 'WV'
            WHEN NPA_STATE IS NOT NULL THEN NPA_STATE
            WHEN PROJ = 'MPAEVC' AND SUBSTR(RUID01,1,2) = '33' THEN 'MI'
            WHEN PROJ = 'MPAEVC' AND SUBSTR(RUID01,1,2) = '31' THEN 'IN'
            WHEN PROJ = 'MPAEVC' AND SUBSTR(RUID01,1,2) = '36' THEN 'OH'
            ELSE SUBSTR(PROJ,-2) END STATE,
       PROJ, NC, CKR, RATE_CODE, BAN, RUID01, RUID02, CUST_EDGE_VLAN, EVC_EVCCKR, BANDWIDTH, clli_code, ALOC, ZLOC,
       ACTL, SPEC, 
       CASE WHEN MRC = 0 THEN NULL ELSE MRC END MRC,
     CASE WHEN NOT evc_meet_point_id01 IS NULL THEN evc_meet_point_id01 ELSE evc_meet_point_id02 END EVC_MEET_POINT_ID,
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
     CASE WHEN ACNA IN ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',      
                        'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWS','AWL','AWN','AZE','BAC',
                        'BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','CBL','CCB','CDA','CEL',
                        'CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
                        'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','ETP','EST','ETX',
                        'FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','HWC',
                        'IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
                        'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ',
                        'MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV',
                        'OSU','PCK','PFM','PIG','RAD','RMC','RMF','RRC','SBM','SBN','SCU','SHI',
                        'SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH',
                        'TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO') THEN 'ATT MOBILITY'
          WHEN ACNA IN ('ABW','APT','ICJ','OPT','PSO','WCG','TZV','PWR','SJV') THEN 'TMOBILE'  
          WHEN ACNA IN ('AEY','IGW','GLF','GUS','CXE','CXJ','DCC','DCX','EIP','ONM','LPL','MJC',         
                        'NLZ','NXT','SWQ','SZC','WEL','WOW','WSO','UBQ','ROW','SPV') THEN 'SPRINT PCS'
          WHEN ACNA IN ('BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','AAK','AHG','AKR','AOK','AUL',       
                        'BAM','BBK','FCO','FCS','IAP','ICN','IDE','IPD','JCC','KOC','FMN','FNT',
                        'GAF','GEX','GMB','GMT','GNL','GTB','GTE','GVU','CLW','CMO','CNL','CNN',
                        'COQ','CRB','CRR','CRY','CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG',
                        'DYT','EBA','ECT','OHC','OMC','PCF','PLP','PPM','LCN','LSC','LTT','MBN',
                        'MCB','MJP','MMH','MMO','NBT','NOH','NVC','NYM','NYR','SRY','SZP','TDQ',
                        'TDU','UTI','UTS','VRZ','ULN','UNV','PTE','PTG','PTI','PTM','PUL','RMB',
                        'RMD','SOT') THEN 'VERIZON WIRELESS'
          WHEN ACNA IN ('UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','USC','WCT') THEN 'US CELLULAR'
          WHEN ACNA IN ('EIW') THEN 'ION'
          WHEN ACNA IN ('SBG') THEN 'SMITH BAGLEY - CELLULAR ONE'
          ELSE NULL END CARRIER_NAME        
FROM
(
SELECT SR.PON,
  SR.DOCUMENT_NUMBER,
  MAX(NL1.CLLI_CODE) keep (dense_rank last order by nl1.last_modified_date) ALOC,
  MAX(NL2.CLLI_CODE) keep (dense_rank last order by nl2.last_modified_date) ZLOC,
  MAX(SUBSTR(NL1.CLLI_CODE,5,2)) keep (dense_rank last order by nl1.last_modified_date)CLLIA,
  MAX(SUBSTR(NL2.CLLI_CODE,5,2)) keep (dense_rank last order by nl2.last_modified_date) CLLIZ, 
  SUBSTR(NPA.EXCHANGE_AREA_CLLI,5,2) NPA_STATE,   
  MAX(SR.ACTIVITY_IND) keep (dense_rank last order by sr.last_modified_date) ACT_IND,
  MAX(SR.SUPPLEMENT_TYPE) keep (dense_rank last order by sr.last_modified_date) SUPP_TYPE,
  MAX(SR.FIRST_ECCKT_ID) keep (dense_rank last order by sr.last_modified_date) CKT,
  max(asr.ic_circuit_reference) keep (dense_rank last order by asr.last_modified_date) ckt2,
  max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) D_REC, 
  max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
  max(AUD.crdd) keep (dense_rank last order by aud.last_modified_date) DDD,
  MAX(AUD.ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) ACCEPT_DT,
  MAX(TRUNC(TSK.ACTUAL_COMPLETION_DATE)) keep (dense_rank last order by tsk.last_modified_date) DD_COMP,
  MAX(ASR.ACCESS_PROVIDER_SERV_CTR_CODE) keep (dense_rank last order by asr.last_modified_date) ICSC,
  MAX(REPLACE(SR.PROJECT_IDENTIFICATION,' ')) keep (dense_rank last order by sr.last_modified_date) PROJ,
  MAX(SR.ACNA) keep (dense_rank last order by sr.last_modified_date) ACNA,
  max(asr.ckr) keep (dense_rank last order by asr.last_modified_date) ckr,
  max(asr.connecting_facility_assignment) keep (dense_rank last order by asr.last_modified_date) CFA,
  MAX(CIR.RATE_CODE) keep (dense_rank last order by cir.last_modified_date) RATE_CODE,
  MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) keep (dense_rank last order by asr.last_modified_date) NC,
  max(aud.ban) keep (dense_rank last order by aud.last_modified_date) ban,  
  max(CIR.EXCHANGE_CARRIER_CIRCUIT_ID) keep (dense_rank last order by cir.last_modified_date) CIRCKT,
  evc1.evc_evcid evc,
  evc1.ruid RUID01, evc2.ruid RUID02, eum1.cust_edge_vlan, evc1.evc_evcckr, evc1.bdw||evc1.bdw2 bandwidth, evc1.evcsp, 
  eum1.evc_meet_point_id evc_meet_point_id01, eum2.evc_meet_point_id evc_meet_point_id02,
  MAX(ASR.promotion_nbr) keep (dense_rank last order by asr.last_modified_date) pnum,
  max(asr.service_and_product_enhanc_cod) keep (dense_rank last order by asr.last_modified_date) SPEC,
  det.actl,
  NVL(ABCLU.MRC,NULL) MRC
  --
FROM SERV_REQ SR, 
     ACCESS_SERVICE_REQUEST ASR, 
     NETWORK_LOCATION NL1,
     NETWORK_LOCATION NL2,
     CIRCUIT CIR,
     DESIGN_LAYOUT_REPORT DLR, 
     TASK TSK,
     ASR_USER_DATA AUD,
     DATA_EXT.ASR_EVC EVC1,
     DATA_EXT.ASR_EVC EVC2,
     EVC_UNI_MAP EUM1,
     EVC_UNI_MAP EUM2,
     NPA_NXX NPA,
     DATA_EXT.asr_sali SALI,
     DATA_EXT.ASR_DETAIL DET,
     ACCESS_BILLING_CIRCUIT_DATA ABCD,
     (SELECT DISTINCT *
        FROM (
        SELECT D.CABS_CIRCUIT_ID,
                     SUM(D.CABS_USOC_AMT) MRC
                   FROM ACCESS_BILLING_CKT_LOC_USOCS D
                   WHERE CABS_USOC_AMT > CABS_QUANTITY_MILES
                   GROUP BY CABS_CIRCUIT_ID
                   )) ABCLU 
--
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = DLR.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)
AND DLR.CIRCUIT_DESIGN_ID = CIR.CIRCUIT_DESIGN_ID (+)
AND CIR.LOCATION_ID = NL1.LOCATION_ID (+)
AND CIR.LOCATION_ID_2 = NL2.LOCATION_ID (+)
AND SR.DOCUMENT_NUMBER = EVC1.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = EVC2.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = EUM1.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = EUM2.DOCUMENT_NUMBER(+)
AND ASR.NPA = NPA.NPA (+)
AND ASR.NXX = NPA.NXX (+)
and SR.DOCUMENT_NUMBER = SALI.DOCUMENT_NUMBER(+)
and sr.document_number = det.document_number (+)
and SR.DOCUMENT_NUMBER = ABCD.DOCUMENT_NUMBER(+)
and ABCD.CABS_CIRCUIT_ID = ABCLU.CABS_CIRCUIT_ID (+)
AND NPA.EXCHANGE_AREA_CLLI(+) <> 'ABCDEFGH'
AND SR.TYPE_OF_SR in ('ASR')
AND TSK.TASK_TYPE = 'DD'
AND (SR.PROJECT_IDENTIFICATION LIKE 'ATTMOB%'
   OR SR.PROJECT_IDENTIFICATION LIKE '%MPAEVC%'
   OR SR.PROJECT_IDENTIFICATION LIKE 'VZW-LTE%'
   OR SR.PROJECT_IDENTIFICATION LIKE 'USCELL%'
   OR SR.PROJECT_IDENTIFICATION LIKE 'ION%'
   OR SR.PROJECT_IDENTIFICATION LIKE 'SPRINT%'
   OR SR.ACNA in ('ADM','AWL','IUW','EIW','MJC','UCU','DTC','EBA','GMT','UNV','WCG','SBG') 
   OR SR.PROJECT_IDENTIFICATION NOT LIKE 'ATTMOBILITY%')
and (RATE_CODE <> 'DS1' OR RATE_CODE IS NULL)
AND (EVC1.UREF = '01' OR EVC1.UREF IS NULL)  
AND (EVC2.UREF = '02' OR EVC2.UREF IS NULL)
AND (EUM1.UNI_REF_NBR = '01' OR EUM1.UNI_REF_NBR IS NULL)  
AND (EUM2.UNI_REF_NBR = '02' OR EUM2.UNI_REF_NBR IS NULL)
--and sr.document_number IN ('3722019')
--
GROUP BY SR.DOCUMENT_NUMBER,
  SR.PON, evc1.evc_evcid, evc1.ruid, evc2.ruid, eum1.cust_edge_vlan, evc1.evc_evcckr, evc1.bdw, evc1.bdw2, evc1.evcsp, 
  eum1.evc_meet_point_id, eum2.evc_meet_point_id,NPA.EXCHANGE_AREA_CLLI, det.actl, ABCLU.MRC         
) z, network_location netloc
where z.evcsp = netloc.location_id (+)
--
and (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)
)
where ACNA in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',            
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
                'RMD','SOT','UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR',
                'UCL','USC','WCT','EIW','WCG','SBG')  
 and (to_char(comp_dt,'yyyy') >= '2015' or comp_dt is null)
 and substr(ckt,7,2) not in ('T1','T3')            
 )
 where product in ('EVC','UNI','NNI','Dark Fiber')
 GROUP BY CARRIER_NAME, PON, SWITCH, TYPE, PORT, USID_FA_PON, EVC_EVCCKR, DOCNO, ACNA, ACT_IND, CKT,
       UNI, MTSO, RUID_SWITCH, D_REC, DD, DDD, COMP_DT, STATUS, STATE, REGION, ICSC, PRODUCT,
       PROJ, CKR, BAN, ALOC, ZLOC, CUST_EDGE_VLAN, BANDWIDTH, EVC_MEET_POINT_ID, PNUM, CFA 
 ORDER BY 19, 18, 16



