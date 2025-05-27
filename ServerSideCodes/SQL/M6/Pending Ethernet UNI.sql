SELECT PON, DOCNO, ACNA, PRIMARY_CARRIER_NAME CARRIER, ACT_IND, REQ_TYPE, CKT, NC, INIT, D_REC CURRENT_RCVD,DD, DDD, ADDRESS, CITY, STATE, ICSC, PRODUCT, PROJ,EUNAME, EXPEDITE                                                                                                                                         
FROM (                                                                                                                                     
SELECT PON, DOCUMENT_NUMBER DOCNO, ACNA, ACT_IND, CKT, TRUNC(ASR_INIT) INIT, TRUNC(D_REC) D_REC, DD, DDD, ACCEPT_DT, DD_COMP DD_TASK_COMP_DT,                                                                                                                                          
       CASE WHEN DD_COMP IS NULL AND ACCEPT_DT > D_REC THEN ACCEPT_DT                                                                                                                                        
            WHEN ACCEPT_DT IS NULL THEN DD_COMP                                                                                                                                    
            WHEN ACCEPT_DT <= DD_COMP AND ACCEPT_DT > D_REC THEN ACCEPT_DT                                                                                                                                     
            ELSE DD_COMP END COMP_DT,                                                                                                                                     
       ICSC, ST STATE, REQ_TYPE,                                                                                                                                    
       CASE WHEN EVC_IND = 'A' THEN 'EVC'
            WHEN EVC_IND = 'B' THEN 'COMBO'
            WHEN SUBSTR(NC,1,1) IN ('H','X','L','O') THEN 'TDM' 
            WHEN UNI_OR_NNI = '435' THEN 'UNI'
            WHEN UNI_OR_NNI = '436' THEN 'NNI'  
            WHEN NC = 'SN' THEN 'NNI'
            WHEN NC = 'KG' THEN 'NNI'                                                                                                                                                                                       
            ELSE NULL END PRODUCT,                                                                                                                            
       PROJ, NC, EUNAME, EXPEDITE, 
       SANO||' '||SASD||' '||SASN||' '||SATH ADDRESS, CITY,
       UNI_OR_NNI                                                                                                                                   
FROM (                                                                                                                                     
SELECT SR.PON, SR.DOCUMENT_NUMBER, SR.ACNA,                                                                                                                                           
  MAX(SR.ACTIVITY_IND) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) ACT_IND,                                                 
  MAX(ASR.REQUEST_TYPE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) REQ_TYPE,                                                    
  MAX(SR.SUPPLEMENT_TYPE) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) SUPP_TYPE,                                                                                                                                        
  C.EXCHANGE_CARRIER_CIRCUIT_ID CKT,                                                                                                                                      
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
  MAX(EXPEDITE_INDICATOR) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EXPEDITE, 
  MAX(ASR.EVC_IND) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EVC_IND,                                   
  EUSA_SEC_SEI SEI,
  MAX(EUNAME) KEEP (DENSE_RANK LAST ORDER BY PI) EUNAME,
  MAX(SANO) KEEP (DENSE_RANK LAST ORDER BY PI) SANO,
  MAX(SASD) KEEP (DENSE_RANK LAST ORDER BY PI) SASD,
  MAX(SASN) KEEP (DENSE_RANK LAST ORDER BY PI) SASN,
  MAX(SATH) KEEP (DENSE_RANK LAST ORDER BY PI) SATH,
  MAX(SALI.CITY) KEEP (DENSE_RANK LAST ORDER BY PI) CITY,
  MAX(SUBSTR(SALI.STATE,1,2)) KEEP (DENSE_RANK LAST ORDER BY PI) ST,
  UNI_OR_NNI                                                                                                                                        
--                                                                                                                                        
FROM SERV_REQ SR,                                                                                                                                         
     ACCESS_SERVICE_REQUEST ASR, 
     SERVICE_REQUEST_CIRCUIT SRC,
     CIRCUIT C,             
     CIRCUIT_USER_DATA CUD,                                                                                                                           
     TASK TSK,                                                                                                                                    
     ASR_USER_DATA AUD,                                                                                                                                    
     DATA_EXT.ASR_SALI SALI,                                                                                                                                    
     NOTES NTS,                                    
     DATA_EXT.ASR_DETAIL DET                                                                                                                                    
--                                                                                                                                        
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = SRC.DOCUMENT_NUMBER (+)  
AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+)   
AND C.CIRCUIT_DESIGN_ID = CUD.CIRCUIT_DESIGN_ID (+)                                                                                   
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)                                                                                                                                        
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)                                                                                                                                        
AND SR.DOCUMENT_NUMBER = SALI.DOCUMENT_NUMBER(+)                                                                                                                                        
AND SR.DOCUMENT_NUMBER = NTS.DOCUMENT_NUMBER(+)                                    
AND SR.DOCUMENT_NUMBER = DET.DOCUMENT_NUMBER (+)                                                                                                                                        
AND SR.TYPE_OF_SR IN ('ASR')                                                                                                                                        
AND ASR.REQUEST_TYPE IN ('S','E')                                                                                                                                        
AND ASR.ACTIVITY_INDICATOR IN ('N','C')                                                                                                                                        
AND TSK.TASK_TYPE = 'DD'                                                                                                                                        
AND TSK.ACTUAL_COMPLETION_DATE IS NULL                                                                                                                                        
AND ACNA NOT IN ('ZZZ','CUS','FLR','ZWV')                                                                                      
--                                                                                                                                        
GROUP BY SR.DOCUMENT_NUMBER, SR.PON, SR.ACNA, EUSA_SEC_SEI, C.EXCHANGE_CARRIER_CIRCUIT_ID, UNI_OR_NNI                                                                                                                                          
)                                                                                                                                          
--                                                                                                                                        
WHERE (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)                                                                                                                                        
AND DD_COMP IS NULL                                                                                                                                         
) SUBQ2,
  ASR_OM.ASR_ACCOUNT_MANAGER AAM                                    
WHERE SUBQ2.ACNA =  AAM.SECONDARY_ID (+)
AND (PRODUCT NOT IN ('TDM','EVC') OR PRODUCT IS NULL)                                                
AND (SUBSTR(CKT,4,1) <> 'V' OR CKT IS NULL)                                     
ORDER BY 9                                    
;
