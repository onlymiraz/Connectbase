SELECT PON, DOCNO, ACNA, ACT_IND, CKT, ADDRESS, CITY, STATE, PRODUCT,
       PNUM, PROJ,EUNAME, TASK_TYPE, WORK_QUEUE_ID, null INIT_ASR, null FIRST_CLEAN,
       null CLEAN_ASR, null INIT_CONF, null FINAL_CONF, DD 
FROM (        
SELECT PON, DOCNO, ACNA, ACT_IND, CKT, INIT, D_REC CURRENT_RCVD,DD, ADDRESS, CITY, STATE, 
       PNUM, PRODUCT, PROJ,EUNAME, EXPEDITE, TASK_TYPE, WORK_QUEUE_ID                                                                                                                         
FROM (                                                                                                        
SELECT PON, DOCUMENT_NUMBER DOCNO, ACNA, ACT_IND, CKT, TRUNC(ASR_INIT) INIT, TRUNC(D_REC) D_REC, DD, PNUM,                                                                                                     
       CASE WHEN UNI_OR_NNI = '436' THEN 'Ethernet-NNI'
            WHEN EVC_IND = 'B' THEN 'Ethernet-Combo'
            WHEN UNI_OR_NNI = '435' THEN 'Ethernet-UNI'
            ELSE NULL END PRODUCT,                                                                                            
       PROJ, NC, EUNAME, EXPEDITE, ADDRESS, CITY, STATE, TASK_TYPE, WORK_QUEUE_ID, EVC_IND                                                                                                    
FROM (                                                                                                      
SELECT SR.PON, SR.DOCUMENT_NUMBER, SR.ACNA,                                                                                                           
  MAX(SR.ACTIVITY_IND) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) ACT_IND,                                                                                                        
  MAX(SR.SUPPLEMENT_TYPE) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) SUPP_TYPE, 
  C.EXCHANGE_CARRIER_CIRCUIT_ID CKT,                                                                                                        
  MIN(NTS.LAST_MODIFIED_DATE) KEEP (DENSE_RANK FIRST ORDER BY NTS.LAST_MODIFIED_DATE) ASR_INIT,                                                                                                        
  MAX(ASR.DATE_TIME_SENT) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) D_REC,                                                                                                         
  MAX(ASR.DESIRED_DUE_DATE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) DD,                                                                                                            
  MAX(TRUNC(TSK.ACTUAL_COMPLETION_DATE)) KEEP (DENSE_RANK LAST ORDER BY TSK.LAST_MODIFIED_DATE) DD_COMP,                                                                                                        
  MAX(ASR.PROMOTION_NBR) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) PNUM,                                                                                                        
  MAX(REPLACE(SR.PROJECT_IDENTIFICATION,' ')) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) PROJ,
  MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NC,
  MAX(ASR.EVC_IND) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EVC_IND,        
  MAX(EXPEDITE_INDICATOR) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EXPEDITE,                                                                                                        
  SALI.EUNAME, SANO||' '||SASD||' '||SASN||' '||SATH ADDRESS, SALI.CITY, SUBSTR(SALI.STATE,1,2) STATE,                                                   
  MAX(T2.TASK_TYPE) KEEP (DENSE_RANK FIRST ORDER BY T2.LAST_MODIFIED_DATE) TASK_TYPE, 
  MAX(T2.WORK_QUEUE_ID) KEEP (DENSE_RANK FIRST ORDER BY T2.LAST_MODIFIED_DATE) WORK_QUEUE_ID,
  CUD.UNI_OR_NNI                                                                                                      
--                                                                                                        
FROM SERV_REQ SR,                                                                                                         
     ACCESS_SERVICE_REQUEST ASR,
     SERVICE_REQUEST_CIRCUIT SRC,                  
     CIRCUIT C,                                                                                       
     TASK TSK,                                                     
     TASK T2,                                                                                                    
     DATA_EXT.ASR_SALI SALI,                                                                                                    
     NOTES NTS,
     CIRCUIT_USER_DATA CUD                                                                                                   
--                                                                                                        
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)  
AND SR.DOCUMENT_NUMBER = SRC.DOCUMENT_NUMBER (+)
AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+)                                                                                                      
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)                                                     
AND SR.DOCUMENT_NUMBER = T2.DOCUMENT_NUMBER (+)                                                                                                        
AND SR.DOCUMENT_NUMBER = SALI.DOCUMENT_NUMBER(+)                                                                                                        
AND SR.DOCUMENT_NUMBER = NTS.DOCUMENT_NUMBER(+)  
AND C.CIRCUIT_DESIGN_ID = CUD.CIRCUIT_DESIGN_ID (+)                                                                                                      
AND SR.TYPE_OF_SR IN ('ASR')                                                                                                                                                                                                                
AND ASR.ACTIVITY_INDICATOR IN ('N')                                                                                                        
AND TSK.TASK_TYPE = 'DD'                                                                                                        
AND TSK.ACTUAL_COMPLETION_DATE IS NULL                                                    
AND T2.TASK_STATUS = 'Ready'                                                                                                        
AND ACNA IN ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM')                  
AND PROMOTION_NBR = 'EPAV001999SCM792'                                                                                  
--                                                                                                        
GROUP BY SR.DOCUMENT_NUMBER, SR.PON, SALI.EUNAME, SANO, SASD, SASN, SATH, SALI.CITY, SALI.STATE, SR.ACNA, CUD.UNI_OR_NNI, C.EXCHANGE_CARRIER_CIRCUIT_ID                                                                                                              
)                                                                                                        
--                                                                                                        
WHERE (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)                                                                                                        
AND DD_COMP IS NULL 
AND (SUBSTR(CKT,4,1) <> 'V' OR CKT IS NULL)                                                                                                       
) 
)
--WHERE DAYS > 49
ORDER BY 20,2;                                                    
