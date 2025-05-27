SELECT PON, DOCNO, MCL.PRIMARY_CARRIER_NAME CARRIER, ACNA, ACT_IND, CKT, INIT, CURRENT_RCVD, DD, DDD, ADDRESS, CITY, STATE, ICSC, PRODUCT,
       PRODUCT_SUB, PROJ,EUNAME, EXPEDITE, TASK_TYPE, WORK_QUEUE_ID, CURRENT_STAGE, DAYS,
       CASE WHEN DAYS >= '150' THEN '150+'
            WHEN DAYS >= '100' THEN '100+' 
            ELSE '75+' END INTERVAL
FROM (        
SELECT PON, DOCNO, ACNA, ACT_IND, CKT, INIT, D_REC CURRENT_RCVD,DD, DDD, ADDRESS, CITY, 
       CASE WHEN STATE = 'VA' THEN 'WV'
            WHEN STATE = 'KY' THEN 'IN'
            ELSE STATE END STATE, 
       ICSC, PRODUCT, evc_ind,
       CASE WHEN PROJ LIKE '%CUT%' THEN 'HOTCUT'
            WHEN PRODUCT IN ('DS0','DS1','DS3','OCN') THEN 'TDM'
            WHEN PRODUCT = 'Ethernet' AND EVC_IND = 'B' THEN 'UNI'
            WHEN PRODUCT = 'Ethernet' AND EVC_IND = 'A' THEN 'EVC' ELSE 'UNI' END PRODUCT_SUB,
      PROJ,EUNAME, EXPEDITE, TASK_TYPE, WORK_QUEUE_ID,
      CASE WHEN EVC_IND = 'A' THEN 'EVC Pending UNI'
           WHEN WORK_QUEUE_ID = 'BDTAMHLD' THEN 'Pending FTR Quote' 
           WHEN WORK_QUEUE_ID = 'BDT_HOLD' THEN 'Held for BDT'
           WHEN TASK_TYPE = 'RUIDCHCK' THEN 'EVC Pending UNI'
           WHEN TASK_TYPE IN ('APP','JEOPHOLD','CARREQ') THEN 'Carrier Action'
           WHEN TASK_TYPE = 'RELASR' THEN 'UNI Construction'
           WHEN TASK_TYPE IN ('BBHOLD','HOLDUNI') THEN 'UNI Provisioning'
           WHEN TASK_TYPE IN ('BUILDCOE','BLDCOEA','COEREVW','COEREVWA') THEN 'COE Engineering'
           WHEN TASK_TYPE IN ('COE_COMP','COECOMPA','COECOMPZ') THEN 'COE Construction'
           WHEN TASK_TYPE IN ('BUILDOSP','OSPREVW','OSP','OSP ZLOC') THEN 'OSP Engineering'
           WHEN TASK_TYPE = 'CON_COMP' THEN 'OSP Construction'
           WHEN TASK_TYPE IN ('CXR/EQ','DLRD') THEN 'Access Engineering'
           WHEN TASK_TYPE IN ('DD','PTD','VNETRESP') THEN 'Dispatch'
           WHEN TASK_TYPE IN ('PRHOTCT','BB_PROV','PROV-ADD','BB_TRANS') THEN 'NPC'
           WHEN TASK_TYPE IN ('ILAM','LAM') THEN 'Assignment'
           WHEN TASK_TYPE = 'UPDTBAN' THEN 'Billing'
           WHEN TASK_TYPE = 'MPEXCHG' THEN 'ICSC'
           WHEN TASK_TYPE = 'CKTID' THEN 'Order Center'
           WHEN TASK_TYPE IN ('VLANPROV','NIDCONFG') then 'EVC Provisioning'
           ELSE NULL END CURRENT_STAGE,
       TRUNC(SYSDATE-INIT) DAYS                                                                                                                         
FROM (                                                                                                        
SELECT PON, DOCUMENT_NUMBER DOCNO, ACNA, ACT_IND, CKT, TRUNC(ASR_INIT) INIT, TRUNC(D_REC) D_REC, DD, DDD, ACCEPT_DT, DD_COMP DD_TASK_COMP_DT,                                                                                                          
       CASE WHEN DD_COMP IS NULL AND ACCEPT_DT > D_REC THEN ACCEPT_DT                                                                                                        
            WHEN ACCEPT_DT IS NULL THEN DD_COMP                                                                                                    
            WHEN ACCEPT_DT <= DD_COMP AND ACCEPT_DT > D_REC THEN ACCEPT_DT                                                                                                     
            ELSE DD_COMP END COMP_DT,                                                                                                     
       ICSC, 
       CASE WHEN ST IS NOT NULL THEN ST ELSE NPASTATE END STATE,                                                                                                    
       CASE WHEN SUBSTR(NC,1,1) IN ('K','V') THEN 'Ethernet'                                                                                                    
            WHEN SUBSTR(CKT,4,1) IN ('K','V') THEN 'Ethernet'                                                                                            
            WHEN SUBSTR(NC,1,1) = 'O' THEN 'OCN'                                                                                            
            WHEN NC = 'HC' THEN 'DS1'                                                                                            
            WHEN NC = 'HF' THEN 'DS3'                                                                                                    
            WHEN SUBSTR(NC,1,1) IN ('L','X') THEN 'DS0'                                                                                            
            ELSE NULL END PRODUCT,                                                                                            
       PROJ, NC, EUNAME, EXPEDITE, ADDRESS, CITY, TASK_TYPE, WORK_QUEUE_ID, EVC_IND                                                                                                    
FROM (                                                                                                        
SELECT SR.PON, SR.DOCUMENT_NUMBER, SR.ACNA,                                                                                                           
  MAX(SR.ACTIVITY_IND) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) ACT_IND,                                                                                                        
  MAX(SR.SUPPLEMENT_TYPE) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) SUPP_TYPE,                                                                                                        
  MAX(SR.FIRST_ECCKT_ID) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) CKT,                                                                                                        
  MIN(NTS.LAST_MODIFIED_DATE) KEEP (DENSE_RANK FIRST ORDER BY NTS.LAST_MODIFIED_DATE) ASR_INIT,                                                                                                        
  MAX(ASR.DATE_TIME_SENT) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) D_REC,                                                                                                         
  MAX(ASR.DESIRED_DUE_DATE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) DD,                                                                                                         
  MAX(AUD.CRDD) KEEP (DENSE_RANK LAST ORDER BY AUD.LAST_MODIFIED_DATE) DDD,                                                                                                        
  MAX(AUD.ACCEPTANCE_DATE) KEEP (DENSE_RANK LAST ORDER BY AUD.LAST_MODIFIED_DATE) ACCEPT_DT,                                                                                                        
  MAX(TRUNC(TSK.ACTUAL_COMPLETION_DATE)) KEEP (DENSE_RANK LAST ORDER BY TSK.LAST_MODIFIED_DATE) DD_COMP,                                                                                                        
  MAX(ASR.ACCESS_PROVIDER_SERV_CTR_CODE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) ICSC,                                                                                                        
  MAX(REPLACE(SR.PROJECT_IDENTIFICATION,' ')) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) PROJ,                                                                                                        
  MAX(SR.FIRST_ECCKT_ID) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) CIRCKT,                                                                                                        
  MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NC,
  MAX(ASR.EVC_IND) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EVC_IND,        
  MAX(EXPEDITE_INDICATOR) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EXPEDITE,                                                                                                        
  SALI.EUNAME, SANO||' '||SASD||' '||SASN||' '||SATH ADDRESS, SALI.CITY, SUBSTR(SALI.STATE,1,2) ST, 
  SUBSTR(NPA.EXCHANGE_AREA_CLLI,5,2) NPASTATE,                                                   
  MAX(T2.TASK_TYPE) KEEP (DENSE_RANK FIRST ORDER BY T2.LAST_MODIFIED_DATE) TASK_TYPE, 
  MAX(T2.WORK_QUEUE_ID) KEEP (DENSE_RANK FIRST ORDER BY T2.LAST_MODIFIED_DATE) WORK_QUEUE_ID                                                                                                       
--                                                                                                        
FROM SERV_REQ SR,                                                                                                         
     ACCESS_SERVICE_REQUEST ASR,                                                                                                         
     TASK TSK,                                                     
     TASK T2,                                                                                                   
     ASR_USER_DATA AUD,                                                                                                    
     DATA_EXT.ASR_SALI SALI,                                                                                                    
     NOTES NTS,
     NPA_NXX NPA                                                                                                   
--                                                                                                        
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)                                                                                                        
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)                                                     
AND SR.DOCUMENT_NUMBER = T2.DOCUMENT_NUMBER (+)                                                                                                       
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)                                                                                                        
AND SR.DOCUMENT_NUMBER = SALI.DOCUMENT_NUMBER(+)                                                                                                        
AND SR.DOCUMENT_NUMBER = NTS.DOCUMENT_NUMBER(+)                                                                                                        
AND SR.TYPE_OF_SR IN ('ASR')                                                                                                        
AND ASR.REQUEST_TYPE IN ('S','E')                                                                                                        
AND ASR.ACTIVITY_INDICATOR IN ('N','C')
AND ASR.NPA = NPA.NPA (+)
AND ASR.NXX = NPA.NXX (+)                                                                                                        
AND TSK.TASK_TYPE = 'DD'                                                                                                        
AND TSK.ACTUAL_COMPLETION_DATE IS NULL                                                    
AND T2.TASK_STATUS = 'Ready'                                                                                                        
AND (ACNA NOT IN ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',
                  'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ','XYY','LGT','LVC','LTL','ATX') OR ACNA IS NULL)                                                                                                     
--                                                                                                        
GROUP BY SR.DOCUMENT_NUMBER, SR.PON, SALI.EUNAME, SANO, SASD, SASN, SATH, SALI.CITY, SALI.STATE, SR.ACNA, NPA.EXCHANGE_AREA_CLLI                                                                                                              
)                                                                                                        
--                                                                                                        
WHERE (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)                                                                                                        
AND DD_COMP IS NULL                                                                                                        
) 
) A, ASR_OM.ASR_ACCOUNT_MANAGER MCL
WHERE A.ACNA =  MCL.SECONDARY_ID
AND DAYS > 74
ORDER BY 7,2;                                                    
