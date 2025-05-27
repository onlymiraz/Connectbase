SELECT TICKET_ID, STATE, CLEC_ID, CKT_ID, PRODUCT, PRODLEV,                                                                                                                                                                
       CREATE_DATE, CLEARED_DT, CLOSED_DT, TTR, MET MISS,                                                                                                                                                                
       REPAIR_CODE, DISP, CLLI_CODE, WORK_ORD, 
       CASE WHEN WORK_ORD IS NOT NULL THEN 'Y' ELSE 'N' END DISPATCH,
       CASE WHEN DISP IN ('CO','FAC') THEN 'F' ELSE 'NF' END FOUND                                                                                                                                                                                                                                                                                                                   
FROM (                                                                                                                                                                
SELECT TICKET_ID, STATE, CLEC_ID, CARRIER, CKT_ID, PRODUCT,
       CASE WHEN PRODUCT = 'DS0' THEN 0
            WHEN PRODUCT = 'DS1' THEN 1
            ELSE 2 END PRODLEV, 
       CREATE_DATE, CLEARED_DT, CLOSED_DT, TTR,                                                                                                                                                                 
       CASE WHEN TTR > 24 THEN 1 ELSE 0 END MET,                                                                                                                                                            
       TRBL_FOUND_CD, TRBL_FOUND_DESC, DISP, CLLI_CODE,                                                                                                                                                            
        REQSTAT, TRBLSTAT, REPAIR_CODE, CAUSECODE, FAULTLOC, WORK_ORD, REQUEST_TYPE, ASSIGNMENTPROFILE, MR2PROD, MR3PROD                                                                                                                                                        
FROM (                                                                                                                                                                
SELECT DISTINCT TICKET_ID, STATE, CLEC_ID, CARRIER, CKT_ID, PRODUCT, CREATE_DATE, CLEARED_DT, CLOSED_DT, TTR,                                                                                                                                                                  
       CASE WHEN TRBL_FOUND_NUMBER IS NOT NULL THEN TRBL_FOUND_NUMBER                                                                                                                                                            
            ELSE TRBL_FOUND_NUMBER2 END TRBL_FOUND_CD,                                                                                                                                                            
       CASE WHEN TRBL_FOUND_DESC IS NOT NULL THEN TRBL_FOUND_DESC                                                                                                                                                            
            ELSE TRBL_FOUND_DESC2 END TRBL_FOUND_DESC,                                                                                                                                                            
       CASE WHEN DISP3 IS NOT NULL THEN DISP3                                                                                                                                                            
            WHEN DISP IS NOT NULL THEN DISP                                                                                                                                                            
            ELSE DISP2 END DISP, CLLI_CODE, REQUEST_TYPE,                                                                                                                                                            
       REQSTAT, TRBLSTAT, REPAIR_CODE, CAUSECODE, FAULTLOC, WORK_ORD, ASSIGNMENTPROFILE,                                                                                                                                                            
       CASE WHEN SUBSTR(CKT_ID,4,4) IN ('TYNU','TYSU') THEN '3221'                                                                                                                                                            
            WHEN SUBSTR(CKT_ID,4,4) IN ('DHSU','AQSU','FZDU','ASDU','HISU') THEN '3223'                                                                                                                                                            
            WHEN SUBSTR(CKT_ID,4,4) IN ('HCFU') THEN '3563'                                                                                                                                                    
            WHEN SUBSTR(CKT_ID,4,4) IN ('HFFU') THEN '3561'                                                                                                                                                    
            ELSE 'UNK' END MR2PROD,                                                                                                                                                    
       CASE WHEN SUBSTR(CKT_ID,4,4) IN ('TYNU','TYSU') AND WORK_ORD IS NOT NULL THEN '3235'                                                                                                                                                            
            WHEN SUBSTR(CKT_ID,4,4) IN ('TYNU','TYSU') AND WORK_ORD IS NULL THEN '3236'                                                                                                                                                            
            WHEN SUBSTR(CKT_ID,4,4) IN ('DHSU','AQSU','FZDU','ASDU','HISU') AND WORK_ORD IS NOT NULL THEN '3241'                                                                                                                                                    
            WHEN SUBSTR(CKT_ID,4,4) IN ('DHSU','AQSU','FZDU','ASDU','HISU') AND WORK_ORD IS NULL THEN '3242'                                                                                                                                                    
            WHEN SUBSTR(CKT_ID,4,4) IN ('HCFU') AND WORK_ORD IS NOT NULL THEN '3585'                                                                                                                                                    
            WHEN SUBSTR(CKT_ID,4,4) IN ('HCFU') AND WORK_ORD IS NULL THEN '3586'                                                                                                                                                    
            WHEN SUBSTR(CKT_ID,4,4) IN ('HFFU') AND WORK_ORD IS NOT NULL THEN '3587'                                                                                                                                                    
            WHEN SUBSTR(CKT_ID,4,4) IN ('HFFU') AND WORK_ORD IS NULL THEN '3588'                                                                                                                                                    
            ELSE 'UNK' END MR3PROD                                                                                                                                                    
FROM (                                                                                                                                                               
SELECT DISTINCT TICKET_ID,                                                                                                                                                                 
       CASE WHEN SITE_STATE IS NOT NULL                                                                                                                                                                 
AND SITE_STATE IN ('WA','OR') THEN SITE_STATE                                                                                                                                                                                    
            WHEN CLLIZ IS NOT NULL                                                                                                                                                                                     
             AND CLLIZ IN ('WA','OR') THEN CLLIZ                                                                                                                                                                             
            WHEN CLLIA IS NOT NULL                                                                                                                                                                                     
             AND CLLIA IN ('WA','OR') THEN CLLIA                                                                                                                                                                            
            WHEN PRILOC IS NOT NULL                                                                                                                                                                                         
             AND PRILOC IN ('WA','OR') THEN PRILOC                                                                                
            ELSE NULL END STATE,                                                                                                                                                                
       CASE WHEN ACNA IS NOT NULL THEN ACNA                                                                                                                                                                
            WHEN ACNA1 IS NOT NULL THEN ACNA1                                                                                                                                                            
            WHEN CCNA1 IS NOT NULL THEN CCNA1                                                                                                                                                            
            WHEN ACNA2 IS NOT NULL THEN ACNA2                                                                                                                                                    
            ELSE CCNA2 END CLEC_ID,                                                                                                                                                                
       Z.CARRIER,                                                                                                                                                             
       CKT_ID,                                                                                                                                                                  
       CASE WHEN SUBSTR(CIRCUIT,3,4) IN ('L1XN','L2XN','L4XN') THEN 'Ethernet'
            WHEN SERVICE_TYPE_CODE IN ('HC','DH','AS','AQ','FZ','IP','UH') THEN 'DS1'                                                                                                                                                    
            WHEN SERVICE_TYPE_CODE IN ('TY','FD') THEN 'DS0'                                                                                                                                                    
            WHEN SERVICE_TYPE_CODE IN ('HF','HI') THEN 'DS3'                 
            WHEN SERVICE_TYPE_CODE IN ('LU','LV','L1','L2','LO','LZ','SX','CU') THEN 'Ethernet'                                                                                                                                                    
            WHEN SUBSTR(CIRCUIT,4,5) LIKE '%T1%' THEN 'DS1'                                                                                                                                                    
            WHEN SUBSTR(CIRCUIT,4,5) LIKE '%T3%' THEN 'DS3'                                                                                                                                                    
            WHEN SUBSTR(CIRCUIT,1,4) LIKE '%HC%' THEN 'DS1'                                                                                                                                                    
            WHEN SUBSTR(CIRCUIT,1,4) LIKE '%HF%' THEN 'DS3'                                                                                                                                                    
            WHEN SUBSTR(SERVICE_TYPE_CODE,1,1) IN ('X','L') THEN 'DS0'                                                                                                                                                    
            WHEN SUBSTR(CIRCUIT,3,1) IN ('X','L') THEN 'DS0'                                                                                                                                                    
            WHEN SUBSTR(SERVICE_TYPE_CODE,1,2) = 'OC' THEN 'OCN'                                                                                                                                                    
            WHEN SUBSTR(CIRCUIT,1,8) LIKE '%OC%' THEN 'OCN'                                                                                                                                                    
            WHEN SUBSTR(CIRCUIT,3,2) IN ('OB','OD','OF','OG') THEN 'OCN'                                                                                                                                                    
            WHEN SUBSTR(SERVICE_TYPE_CODE,1,1) IN ('K','V') THEN 'Ethernet'                                                                                                                                                    
            WHEN SUBSTR(CIRCUIT,3,1) IN ('K','V') THEN 'Ethernet'                                                                                                                                                
            WHEN RATE_CODE IN ('OC3','OC12','OC48','OC192') THEN 'OCN' 
            WHEN RATE_CODE IN ('DS3') THEN 'DS3'                                                                                                                            
            ELSE ' ' END PRODUCT,                                                                                                                                                    
       CREATE_DATE,             
       CASE WHEN CLEARED_DT IS NOT NULL THEN CLEARED_DT         
            ELSE CLOSED_DT END CLEARED_DT,             
       CASE WHEN CLOSED_DT IS NOT NULL THEN CLOSED_DT                
            ELSE CLEARED_DT END CLOSED_DT,                                                                                                                                                                                                                                                                                                                              
       TTR,                                                                                                                                                               
       B.TRBL_FOUND_NUMBER, B.TRBL_FOUND_DESC, B.DISP, C.TRBL_FOUND_NUMBER TRBL_FOUND_NUMBER2, C.TRBL_FOUND_DESC TRBL_FOUND_DESC2, C.DISP DISP2, D.DISP DISP3,                                                                                                                                                            
       CLLI_CODE, ACLLI, AEXCH, ZCLLI, ZEXCH,                                                                                                                                                            
       REQSTAT, TRBLSTAT, Z.REPAIR_CODE, CAUSECODE, FAULTLOC, WORK_ORD, REQUEST_TYPE, ASSIGNMENTPROFILE                                                                                                                                                                                                                                                                                               
FROM (           
 --                
SELECT TICKET_ID, SITE_STATE, CKT_ID, CIRCUIT, Y.ACNA, REQUEST_TYPE, CREATE_DATE,        
       CLEARED_DT, CLOSED_DT,  
       CASE WHEN TTR IS NULL THEN ROUND((CLEARED_DT-CREATE_DATE)*24,2)
            WHEN TTR <0 THEN ROUND((CLEARED_DT-CREATE_DATE)*24,2) 
       ELSE TTR END TTR,
       REPAIR_CODE, REQSTAT, TRBLSTAT, CAUSECODE, FAULTLOC,        
       ASSIGNMENTPROFILE, SERVICE_TYPE_CODE, RATE_CODE, TRBL_FOUND_CD, TYPE, WORK_ORD,        
       MAX(UPPER(D.EC_COMPANY_CODE)) KEEP (DENSE_RANK LAST ORDER BY D.LAST_MODIFIED_DATE) ICSC,          
       MAX(TRIM(D.ACNA)) KEEP (DENSE_RANK LAST ORDER BY D.LAST_MODIFIED_DATE) ACNA1,         
       MAX(TRIM(D.CCNA)) KEEP (DENSE_RANK LAST ORDER BY D.LAST_MODIFIED_DATE) CCNA1,    
       MAX(TRIM(D.ACNA)) KEEP (DENSE_RANK FIRST ORDER BY D.ACNA) ACNA2, 
       MAX(TRIM(D.CCNA)) KEEP (DENSE_RANK FIRST ORDER BY D.CCNA) CCNA2,  
       MAX(SUBSTR(D.PRIMARY_LOCATION,5,2)) KEEP (DENSE_RANK LAST ORDER BY D.LAST_MODIFIED_DATE) PRILOC,   
       MAX(SUBSTR(F.CLLI_CODE,5,2)) KEEP (DENSE_RANK LAST ORDER BY F.LAST_MODIFIED_DATE) CLLIA,        
       MAX(SUBSTR(F2.CLLI_CODE,5,2)) KEEP (DENSE_RANK LAST ORDER BY F2.LAST_MODIFIED_DATE) CLLIZ,    
       MAX(F2.CLLI_CODE) KEEP (DENSE_RANK LAST ORDER BY F2.LAST_MODIFIED_DATE) CLLI_CODE,   
       MAX(D.INTEREXCHANGE_CARRIER_NAME) KEEP (DENSE_RANK LAST ORDER BY D.LAST_MODIFIED_DATE) CARRIER,    
       MAX(SUBSTR(F.CLLI_CODE,1,6)) KEEP (DENSE_RANK LAST ORDER BY F.LAST_MODIFIED_DATE) ACLLI,           
       MAX(SUBSTR(F.EXCHANGE_AREA_CLLI,1,6)) KEEP (DENSE_RANK LAST ORDER BY F.LAST_MODIFIED_DATE) AEXCH,                                                                                                                                                            
       MAX(SUBSTR(F2.CLLI_CODE,1,6)) KEEP (DENSE_RANK LAST ORDER BY F2.LAST_MODIFIED_DATE) ZCLLI,                                                                                                                                                            
       MAX(SUBSTR(F2.EXCHANGE_AREA_CLLI,1,6)) KEEP (DENSE_RANK LAST ORDER BY F2.LAST_MODIFIED_DATE) ZEXCH        
FROM (        
--                                                                                                                                                           
SELECT A.FLD_REQUESTID TICKET_ID,                                                                                                                                                                 
       MAX(SUBSTR(A.FLD_SITEID,5,2)) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) SITE_STATE,                                                                                                                                                                                                                                                 
       A.EXCHANGE_CARRIER_CIRCUIT_ID CKT_ID,                                                                                                                                                             
       REPLACE(REPLACE(A.EXCHANGE_CARRIER_CIRCUIT_ID,' '),'/') CIRCUIT,                                                                                                                                                            
       MAX(A.ACNA) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) ACNA,                                                                                                                                                                                                                                                                                                               
       MAX(A.FLD_REQUESTTYPE) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) REQUEST_TYPE,                                                                                                                                                             
       MAX(A.FLD_STARTDATE) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) CREATE_DATE,                                                                                                                                                            
       MAX(A.FLD_EVENT_END_TIME) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) CLEARED_DT,                                                                                                                                                             
       MAX(A.DTE_CLOSEDDATETIME) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) CLOSED_DT,                                                                                                                                                                
       MAX(ROUND(A.FLD_MTTREPAIR/3600,2)) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) TTR,                                                                                                                                                            
       MAX(ROUND(A.H_FLD_TOTALOPENTIME_SECS_/3600,2)) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) TOTAL_DURATION,                                                                                                                                                            
       MAX(FLD_COMPLETE_REPAIRCODE) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) REPAIR_CODE,                                                                                                                                                            
       MAX(FLD_TROUBLEFOUNDINT) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) TRBL_FOUND_CD,                                                                                                                                                              
       MAX(E.TYPE) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) TYPE,                                                                                                                                                                
       MAX(E.SERVICE_TYPE_CODE) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) SERVICE_TYPE_CODE,                                                                                                                                                             
       MAX(E.RATE_CODE) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) RATE_CODE,                                                                                                                                                                                                                                                 
       MAX(A.FLD_REQUESTSTATUS) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) REQSTAT,                                                                                                                                                            
       MAX(A.FLD_TROUBLEREPORTSTATE) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) TRBLSTAT,                                                                                                                                                            
       MAX(A.FLD_COMPLETE_CAUSECODE) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) CAUSECODE,                                                                                                                                                            
       MAX(A.FLD_COMPLETE_FAULTLOCATION) KEEP (DENSE_RANK LAST ORDER BY A.FLD_MODIFIEDDATE) FAULTLOC,                                                                                                                                                            
       MAX(B.FLD_REQUESTID) KEEP (DENSE_RANK LAST ORDER BY B.DW_LOAD_DATE_TIME) WORK_ORD,                
       MAX(TRIM(A.FLD_ASSIGNMENTPROFILE)) KEEP (DENSE_RANK FIRST ORDER BY A.FLD_MODIFIEDDATE) ASSIGNMENTPROFILE ,        
       MAX(E.LOCATION_ID) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) LOCATION_ID,        
       MAX(E.LOCATION_ID_2) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) LOCATION_ID_2                                                                                                                                                           
FROM CASDW.TROUBLE_TICKET_R A,                                                                                                    
     CASDW.WORK_ORDER_R B,                                                                                                                                                                                                                                                                                  
     CASDW.CIRCUIT E                                                                                                                                                                                                                                                                                                    
WHERE A.FLD_TROUBLEREPORTSTATE = 'closed'                                                                                                                                                                
 AND A.FLD_REQUESTID = B.FLD_TICKETID (+)                                                                                                                                                               
 AND A.EXCHANGE_CARRIER_CIRCUIT_ID = E.EXCHANGE_CARRIER_CIRCUIT_ID(+)                                                                                                                                                                     
 AND (TO_CHAR(DTE_CLOSEDDATETIME,'yyyymm') = '202004'                    
    OR (DTE_CLOSEDDATETIME IS NULL AND TO_CHAR(FLD_EVENT_END_TIME,'yyyymm') = '202004'))                   
 AND (A.ACNA IN ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',                                                                                                                                                                                            
                 'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ') OR A.ACNA IS NULL)                                                                                                                                                                   
GROUP BY A.FLD_REQUESTID, A.EXCHANGE_CARRIER_CIRCUIT_ID         
--        
) Y,        
  CASDW.DESIGN_LAYOUT_REPORT D,        
  CASDW.NETWORK_LOCATION F,                                                                                                                                                            
  CASDW.NETWORK_LOCATION F2        
WHERE Y.CKT_ID = D.ECCKT(+)        
  AND Y.LOCATION_ID = F.LOCATION_ID(+)                                                                                                                                                                
  AND Y.LOCATION_ID_2 = F2.LOCATION_ID(+)        
  AND REQSTAT = 'Closed'                  
  AND (TYPE <> 'T' OR TYPE IS NULL)                 
  AND REQUEST_TYPE NOT IN ('Alarm','Information')                
  AND ASSIGNMENTPROFILE NOT LIKE 'Tier%'        
GROUP BY TICKET_ID, SITE_STATE, CKT_ID, CIRCUIT, Y.ACNA, REQUEST_TYPE, CREATE_DATE,        
       CLEARED_DT, CLOSED_DT, TTR, TOTAL_DURATION, REPAIR_CODE, REQSTAT, TRBLSTAT, CAUSECODE, FAULTLOC,        
       ASSIGNMENTPROFILE, SERVICE_TYPE_CODE, RATE_CODE, TRBL_FOUND_CD, TYPE, WORK_ORD                                                                                                                                                               
) Z, TRBL_FOUND_REMEDY B, REPAIR_CODE C, TRBL_FOUND_REMEDY D                                                                                                                                                                
WHERE Z.TRBL_FOUND_CD = B.TRBL_FOUND_NUMBER (+)                                                                                                                                                                
AND Z.REPAIR_CODE = C.REPAIR_CODE (+)                                                                                                                                                                
AND Z.REPAIR_CODE = D.TRBL_FOUND_DESC (+)                                                                                                                                                                                            
)                                                                                                                                                                                            
WHERE DISP IN ('CO','FAC','CC','NTF')                  
AND STATE IN ('WA','OR')                                                                                                             
AND (CLEC_ID IN ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',                                                                                                                                                                                            
                 'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ') OR CLEC_ID IS NULL)                                                                                                                                                                                             
)                                                                                                                                                                                                                                                                                                                                                                     
) 
WHERE PRODUCT IN ('DS0','DS1','DS3','OCN','Ethernet')                                                                                                                                                                                           
ORDER BY 2,4,6;                   
