SELECT DOCNO, PON, ACNA, ACT_IND, REQ_TYPE, CKT, 
       CASE WHEN INIT <= D_REC THEN INIT ELSE D_REC END INIT,
       D_REC CURRENT_RCVD,DD, DDD, STATE, 
       CASE WHEN STATE IN ('CT','NY','PA','AL','FL','GA','MS','NC','SC','TN') then 'Eastern'
            WHEN STATE IN ('IA','IL','IN','MI','MN','NE','WI','KY','TX','OH','WV','MD','VA') then 'Central'
       		WHEN STATE IN ('CA','AZ','NM','NV','UT') then 'Western'
	  	    ELSE 'Unknown' END REGION,
       CASE WHEN STATE IN ('AL','GA','MS','TN') THEN 'SOUTH STATES'
            WHEN STATE IN ('IA','MN','NE') THEN 'MID STATES'
            WHEN STATE IN ('AZ','NM','NV') THEN 'SOUTHWEST'
            WHEN STATE = 'VA' THEN 'WV'
            ELSE STATE END AREA,      
       ICSC, PROJ, EXPEDITE, PRODUCT , EVC_IND                                                                                                                                                 
FROM (                                                                                                                                                  
SELECT PON, DOCUMENT_NUMBER DOCNO, ACNA, ACT_IND, CKT, TRUNC(ASR_INIT) INIT, TRUNC(D_REC) D_REC, DD, DDD, ACCEPT_DT, DD_COMP DD_TASK_COMP_DT,                                                                                                                                                      
       CASE WHEN DD_COMP IS NULL AND ACCEPT_DT > D_REC THEN ACCEPT_DT                                                                                                                                                    
            WHEN ACCEPT_DT IS NULL THEN DD_COMP                                                                                                                                                
            WHEN ACCEPT_DT <= DD_COMP AND ACCEPT_DT > D_REC THEN ACCEPT_DT                                                                                                                                                 
            ELSE DD_COMP END COMP_DT,                                                                                                                                                 
       ICSC, REQ_TYPE, EVC_IND, 
       CASE WHEN GA_STATE IS NOT NULL THEN GA_STATE
            WHEN SUBSTR(N.EXCHANGE_AREA_CLLI,5,2) NOT IN ('EF','LE') THEN SUBSTR(N.EXCHANGE_AREA_CLLI,5,2)
            WHEN ICSC = 'GT10' AND SUBSTR(CKT,1,2) IN ('69','65') THEN 'FL'
            WHEN ICSC = 'GT10' AND SUBSTR(CKT,1,2) IN ('81','45') THEN 'CA'
            WHEN ICSC = 'GT10' AND SUBSTR(CKT,1,2) IN ('12','13') THEN 'TX'
            WHEN ICSC = 'SN01' THEN 'CT'
            ELSE NULL END STATE,                                                                                                                                                 
       CASE WHEN EVC_IND = 'B' THEN 'Combo'                                                
            WHEN NC = 'SN' THEN 'NNI'
            WHEN SUBSTR(NC,1,1) = 'K' THEN 'UNI'                                                                                                                                                                                                                                     
            ELSE NULL END PRODUCT,               
       CASE WHEN SUBSTR(CKT,4,1) = 'V' THEN 'EVC'
            WHEN SUBSTR(CKT,4,2) = 'CU' THEN 'EVC'
            ELSE NULL END CIRC_PROD,                                                                                                                              
       PROJ, NC, EXPEDITE                                                                                                                                               
FROM (                                                                                                                                                   
SELECT SR.PON, SR.DOCUMENT_NUMBER, SR.ACNA,                                                                                                                                                       
  MAX(SR.ACTIVITY_IND) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) ACT_IND,                                                             
  MAX(ASR.REQUEST_TYPE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) REQ_TYPE,                                                                
  MAX(SR.SUPPLEMENT_TYPE) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) SUPP_TYPE,                                                                                                                                                     
  MIN(NTS.LAST_MODIFIED_DATE) KEEP (DENSE_RANK FIRST ORDER BY NTS.LAST_MODIFIED_DATE) ASR_INIT,                                                                                                                                                    
  MAX(ASR.DATE_TIME_SENT) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) D_REC,                                                                                                                                                     
  MAX(ASR.DESIRED_DUE_DATE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) DD,                                                                                                                                                     
  MAX(AUD.CRDD) KEEP (DENSE_RANK LAST ORDER BY AUD.LAST_MODIFIED_DATE) DDD,                                                                                                                                                    
  MAX(AUD.ACCEPTANCE_DATE) KEEP (DENSE_RANK LAST ORDER BY AUD.LAST_MODIFIED_DATE) ACCEPT_DT,                                                                                                                                                    
  MAX(TRUNC(TSK.ACTUAL_COMPLETION_DATE)) KEEP (DENSE_RANK LAST ORDER BY TSK.LAST_MODIFIED_DATE) DD_COMP,                                                                                                                                                    
  MAX(ASR.ACCESS_PROVIDER_SERV_CTR_CODE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) ICSC,                                                                                                                                                    
  MAX(REPLACE(SR.PROJECT_IDENTIFICATION,' ')) KEEP (DENSE_RANK LAST ORDER BY SR.LAST_MODIFIED_DATE) PROJ,
  C.EXCHANGE_CARRIER_CIRCUIT_ID CKT,                                                                                                                                                    
  MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NC,                                                                                                                                                    
  MAX(EXPEDITE_INDICATOR) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EXPEDITE, 
  MAX(ASR.EVC_IND) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EVC_IND,
  MAX(ASR.NPA) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NPA,
  MAX(ASR.NXX) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NXX,
  GAI.INSTANCE_VALUE_ABBREV GA_STATE                                                                                                                                                 
--                                                                                                                                                    
FROM SERV_REQ SR,                                                                                                                                                     
     ACCESS_SERVICE_REQUEST ASR,                                                                                                                                                     
     TASK TSK,                                                                                                                                                
     ASR_USER_DATA AUD,
     ASAP.SERVICE_REQUEST_CIRCUIT SRC, 
     CIRCUIT C,                                                                                                                                                    
     NOTES NTS,
     SR_LOC LOC,
     ADDRESS ADDR,
     GA_INSTANCE GAI
                                                                                                                                                            
--                                                                                                                                                    
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)                                                                                                                                                    
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)                                                                                                                                                    
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = SRC.DOCUMENT_NUMBER (+)
AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+)                                                                                                                                                   
AND SR.DOCUMENT_NUMBER = NTS.DOCUMENT_NUMBER(+) 
AND SR.DOCUMENT_NUMBER = LOC.DOCUMENT_NUMBER(+)
AND LOC.ADDRESS_ID (+) IS NOT NULL
AND LOC.ADDRESS_ID = ADDR.ADDRESS_ID (+)
AND ADDR.ADDR_VALID_IND (+) = 'Y'
AND ADDR.GA_INSTANCE_ID_STATE_CD = GAI.GA_INSTANCE_ID (+)
AND GAI.GAT_TYPE_NM (+) = 'STATE'
AND GAI.GAT_TYPE_COUNTRY_EXT_ID (+) = 47                                                                                                     
AND SR.TYPE_OF_SR IN ('ASR')                                                                                                                                                    
AND ASR.REQUEST_TYPE IN ('S','E')                                                                                                                                                    
AND ASR.ACTIVITY_INDICATOR IN ('N','C')                                                                                                                                                    
AND TSK.TASK_TYPE = 'DD'                                                                                                                                              
AND TSK.ACTUAL_COMPLETION_DATE IS NULL                                                                                                                                                    
AND (ACNA NOT IN ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',
                  'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ','XYY') OR ACNA IS NULL)                                                                                                    
--                                                                                                                                                    
GROUP BY SR.DOCUMENT_NUMBER, SR.PON, SR.ACNA, C.EXCHANGE_CARRIER_CIRCUIT_ID, GAI.INSTANCE_VALUE_ABBREV                                                                                                                                                      
)                                                                                                                                                    
--  
A, NPA_NXX N                                                                                                                                                  
WHERE A.NPA = N.NPA (+)
AND A.NXX = N.NXX (+) 
AND (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)                                                                                                                                                    
AND DD_COMP IS NULL                                                                                                                                             
)                                                 
WHERE PRODUCT IN ('UNI','NNI','Combo')    
  AND CIRC_PROD IS NULL                                                                                               
ORDER BY 7;                                                
