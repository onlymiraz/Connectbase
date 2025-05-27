DROP TABLE JPSAMR                        
/                                                                                                                                                                                                                                        
                                                                                
CREATE TABLE JPSAMR NOLOGGING NOCACHE AS                                                                                                                                                                                        
SELECT TICKET_ID, STATE, CLEC_ID, CKT_ID, PRODUCT, CREATE_DATE,                                                                                                                                                                                          
       CLEARED_DT, CLOSED_DT, TO_CHAR(CLOSED_DT,'MM')||'/01/'||TO_CHAR(CLOSED_DT,'YYYY') MNTH,                                                                                                                                                                                        
       TTR, MET MISS, REPAIR_CODE, DISP, 
       CASE WHEN DISP IN ('CO','FAC') THEN 'F' ELSE 'NF' END FOUND,
       CLLI_CODE, DISPATCH, MR2PROD, MR3PROD, 1 CNT                                                                                                                                                                                                                                                                                                                                                                           
FROM (                                                                                                                                                                                        
SELECT TICKET_ID, STATE, CLEC_ID, CARRIER, CKT_ID, PRODUCT, CREATE_DATE, CLEARED_DT, CLOSED_DT,                                                                                                                                                                                          
       TTR,                                                                                                                                                                                         
       CASE WHEN TTR > 24 THEN 1 ELSE 0 END MET,                                                                                                                                                                                    
       TRBL_FOUND_CD, TRBL_FOUND_DESC, DISP, CLLI_CODE,                                                                                                                                                                                    
        REQSTAT, TRBLSTAT, REPAIR_CODE, CAUSECODE, FAULTLOC, DISPATCH, MR2PROD, MR3PROD                                                                                                                                                                                
FROM (                                                                                                                                                                                        
SELECT DISTINCT TICKET_ID, STATE, CLEC_ID, CARRIER, CKT_ID, PRODUCT, CREATE_DATE, CLEARED_DT, CLOSED_DT,                                                                                                                                                                                         
       TTR,                                                                                                                                                                                          
       CASE WHEN TRBL_FOUND_NUMBER IS NOT NULL THEN TRBL_FOUND_NUMBER                                                                                                                                                                                    
            ELSE TRBL_FOUND_NUMBER2 END TRBL_FOUND_CD,                                                                                                                                                                                    
       CASE WHEN TRBL_FOUND_DESC IS NOT NULL THEN TRBL_FOUND_DESC                                                                                                                                                                                    
            ELSE TRBL_FOUND_DESC2 END TRBL_FOUND_DESC,                                                                                                                                                                                    
       CASE WHEN DISP3 IS NOT NULL THEN DISP3                                                                                                                                                                                    
            WHEN DISP IS NOT NULL THEN DISP                                                                                                                                                                                    
            ELSE DISP2 END DISP, CLLI_CODE,                                                                                                                                                                                    
       REQSTAT, TRBLSTAT, REPAIR_CODE, CAUSECODE, FAULTLOC, 
       CASE WHEN WORK_ORD IS NOT NULL THEN 'Yes' ELSE 'No' END DISPATCH,                                                                                                                                                                                    
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
             AND SITE_STATE IN ('OR','WA') THEN SITE_STATE                                                                                                                                                                                                            
            WHEN CLLIZ IS NOT NULL                                                                                                                                                                                                             
             AND CLLIZ IN ('OR','WA') THEN CLLIZ                                                                                                                                                                                                     
            WHEN CLLIA IS NOT NULL                                                                                                                                                                                                             
             AND CLLIA IN ('OR','WA') THEN CLLIA                                                                                                                                                                                                    
            WHEN PRILOC IS NOT NULL                                                                                                                                                                                                                 
             AND PRILOC IN ('OR','WA') THEN PRILOC                                                                                                        
            ELSE NULL END STATE,                                                                                                                                                                                        
       CASE WHEN ACNA IS NOT NULL THEN ACNA                                                                                                                                                                                        
            WHEN ACNA1 IS NOT NULL THEN ACNA1                                                                                                                                                                                    
            WHEN CCNA1 IS NOT NULL THEN CCNA1                                                                                                                                                                                    
            WHEN ACNA2 IS NOT NULL THEN ACNA2                                                                                                                                                                            
            ELSE CCNA2 END CLEC_ID,                                                                                                                                                                                        
       CARRIER,                                                                                                                                                                                     
       CKT_ID,                                                                                                                                                                                          
       CASE WHEN SERVICE_TYPE_CODE = 'HC' THEN 'DS1'                                                                                                                                                                                    
            WHEN SERVICE_TYPE_CODE = 'DH' THEN 'DS1'                                                                                                                                                                            
            WHEN SERVICE_TYPE_CODE = 'AS' THEN 'DS1'                                                                                                                                                                            
            WHEN SERVICE_TYPE_CODE = 'AQ' THEN 'DS1'                                                                                                                                                                            
            WHEN SERVICE_TYPE_CODE = 'FZ' THEN 'DS1'                                                                                                                                                                            
            WHEN SERVICE_TYPE_CODE = 'TY' THEN 'DS0'                                                                                                                                                                            
            WHEN SERVICE_TYPE_CODE = 'HF' THEN 'DS3'                                                                                                                                                                            
            WHEN SERVICE_TYPE_CODE = 'HI' THEN 'DS3'                                                                                                                                                                            
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
            ELSE ' ' END PRODUCT,                                                                                                                                                                            
       CREATE_DATE, CLEARED_DT,                                         
       CASE WHEN CLOSED_DT IS NOT NULL THEN CLOSED_DT                                    
            ELSE CLEARED_DT END CLOSED_DT,                                                                                                                                                                                         
       TTR,                                                                                                                                                                                    
       B.TRBL_FOUND_NUMBER, B.TRBL_FOUND_DESC, B.DISP, C.TRBL_FOUND_NUMBER TRBL_FOUND_NUMBER2, C.TRBL_FOUND_DESC TRBL_FOUND_DESC2, C.DISP DISP2, D.DISP DISP3,                                                                                                                                                                                    
       CLLI_CODE, ACLLI, AEXCH, ZCLLI, ZEXCH,                                                                                                                                                                                    
       REQSTAT, TRBLSTAT, A.REPAIR_CODE, CAUSECODE, FAULTLOC, WORK_ORD                                                                                                                                                                                    
FROM (  
--
SELECT TICKET_ID, SITE_STATE, CKT_ID, CIRCUIT, A.ACNA, REQUEST_TYPE, CREATE_DATE,
       CLEARED_DT, CLOSED_DT, TTR, REPAIR_CODE, TRBL_FOUND_CD, TYPE, SERVICE_TYPE_CODE, REQSTAT,
       RATE_CODE, TRBLSTAT, CAUSECODE, FAULTLOC, WORK_ORD,
       MAX(UPPER(D.EC_COMPANY_CODE)) KEEP (DENSE_RANK LAST ORDER BY D.LAST_MODIFIED_DATE) ICSC,                                                                                                                                                                                     
       MAX(SUBSTR(D.PRIMARY_LOCATION,5,2)) KEEP (DENSE_RANK LAST ORDER BY D.LAST_MODIFIED_DATE) PRILOC,                                                                                                                                                                                         
       MAX(SUBSTR(F.CLLI_CODE,5,2)) KEEP (DENSE_RANK LAST ORDER BY F.LAST_MODIFIED_DATE) CLLIA,                                                                                                                                                                                    
       MAX(SUBSTR(F2.CLLI_CODE,5,2)) KEEP (DENSE_RANK LAST ORDER BY F2.LAST_MODIFIED_DATE) CLLIZ,                                                                                                                                                                                    
       MAX(F2.CLLI_CODE) KEEP (DENSE_RANK LAST ORDER BY F2.LAST_MODIFIED_DATE) CLLI_CODE,    
       MAX(D.ACNA) KEEP (DENSE_RANK LAST ORDER BY D.LAST_MODIFIED_DATE) ACNA1,                                                                                                                                                                                         
       MAX(D.CCNA) KEEP (DENSE_RANK LAST ORDER BY D.LAST_MODIFIED_DATE) CCNA1,                                                                                                                                                                                    
       MAX(D.ACNA) KEEP (DENSE_RANK FIRST ORDER BY D.LAST_MODIFIED_DATE) ACNA2,                                                                                                                                                                                     
       MAX(D.CCNA) KEEP (DENSE_RANK FIRST ORDER BY D.LAST_MODIFIED_DATE) CCNA2,
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
       MAX(E.LOCATION_ID) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) LOCATION_ID,
       MAX(E.LOCATION_ID_2) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) LOCATION_ID_2                                                                                                                                                                                    
FROM CASDW.TROUBLE_TICKET_R A,                                                                                                                            
     CASDW.WORK_ORDER_R B,
     CASDW.CIRCUIT E                                                                                                                                                                                          
WHERE A.FLD_TROUBLEREPORTSTATE = 'closed'                                                                                                                                                                                        
 AND A.FLD_ASSIGNMENTPROFILE = 'CNOC'                                                                                                       
 AND A.FLD_REQUESTID = B.FLD_TICKETID (+)                                                                                                                                                                                                                                                                                                                                                                               
 AND A.EXCHANGE_CARRIER_CIRCUIT_ID = E.EXCHANGE_CARRIER_CIRCUIT_ID(+)    
 AND (E.TYPE <> 'T' OR TYPE IS NULL)                                                                                                                                                                                         
 AND E.STATUS (+) = '6'                                                                                                                                                                                        
 AND (TO_CHAR(DTE_CLOSEDDATETIME,'yyyymm') = '202004'  --CHANGE THE DATE EACH MONTH                                                        
   OR (DTE_CLOSEDDATETIME IS NULL AND TO_CHAR(FLD_EVENT_END_TIME,'yyyymm') = '202004'))  --CHANGE THE DATE EACH MONTH                                                                                                                                                                                                   
GROUP BY A.FLD_REQUESTID, A.EXCHANGE_CARRIER_CIRCUIT_ID
--
) A,
  CASDW.DESIGN_LAYOUT_REPORT D,                                                                                                                                 
  CASDW.NETWORK_LOCATION F,                                                                                                                                                                                    
  CASDW.NETWORK_LOCATION F2
WHERE A.CKT_ID = D.ECCKT(+)
 AND A.LOCATION_ID = F.LOCATION_ID(+)
 AND A.LOCATION_ID_2 = F2.LOCATION_ID(+)
GROUP BY TICKET_ID, SITE_STATE, CKT_ID, CIRCUIT, A.ACNA, REQUEST_TYPE, CREATE_DATE,
         CLEARED_DT, CLOSED_DT, TTR, REPAIR_CODE, TRBL_FOUND_CD, TYPE, SERVICE_TYPE_CODE, REQSTAT,
         RATE_CODE, TRBLSTAT, CAUSECODE, FAULTLOC, WORK_ORD  
--
) A, TRBL_FOUND_REMEDY B, REPAIR_CODE C, TRBL_FOUND_REMEDY D                                                                                                                                                                                        
WHERE A.TRBL_FOUND_CD = B.TRBL_FOUND_NUMBER (+)                                                                                                                                                                                        
AND A.REPAIR_CODE = C.REPAIR_CODE (+)                                                                                                                                                                                        
AND A.REPAIR_CODE = D.TRBL_FOUND_DESC (+)                                                                                                                                                                                        
AND SUBSTR(CIRCUIT,6,1) = 'U'                                                                                                                                                                                           
AND REQUEST_TYPE IN ('Agent','Alarm','Customer','Maintenance')                                                                                                                                                                                        
AND SUBSTR(CKT_ID,4,2) NOT IN ('VM','EM','IP','IB','FX','YB','YG','UG','UH','RT','PL','LA','LU','XA','LA','LO','LN','LU','FD','US','CS')                                                                                                                                                                                        
AND REQSTAT = 'Closed'                                                                                                                                                                                        
)DATA,                                                                                                                                                                                         
 RVV827.CARRIER_LIST CL                                                                                                                                                                                        
WHERE CLEC_ID = CL.ACNA(+)                                                                                                                                                                                        
AND DATA.STATE IN ('OR','WA')                                                                                                         
AND (CLEC_ID NOT IN ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',                                                                                                                                                                                        
                     'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ','GOV') AND CLEC_ID IS NOT NULL)                                                                                                                                                                                      
)                                                                                                                                                                                        
WHERE DISP IN ('CO','FAC','CC','NTF') 
AND MR2PROD IN ('3223','3561','3563')                                                                                                                                                                                       
)                                                                                                                                                                                        
ORDER BY 1,2,3,4;



--CLEC DETAIL 
SELECT * FROM JPSAMR
ORDER BY 2,3,4;



--AGGREGATE  
SELECT STATE, MNTH, 'MR-2-01-'||MR2PROD PROD, MR2PROD,
       SUM(CNT) NUM, NULL DEN, NULL RES, 
       NULL INUM, NULL IDEN, NULL IRES
FROM JPSAMR
GROUP BY STATE, MNTH, MR2PROD
UNION ALL
SELECT STATE, MNTH, 'MR-3-01-'||MR3PROD PROD, MR3PROD,
       SUM(MISS) NUM, COUNT(*) DENOM, ROUND((SUM(MISS)/COUNT(*))*100,2) RES,
       NULL INUM, NULL IDEN, NULL IRES
FROM JPSAMR
GROUP BY STATE, MNTH, MR3PROD
UNION ALL
SELECT STATE, MNTH, 'MR-4-01-'||MR3PROD PROD, MR3PROD,
       SUM(TTR) NUM, COUNT(*) DENOM, ROUND(SUM(TTR)/COUNT(*),2) RES,
       NULL INUM, NULL IDEN, NULL IRES
FROM JPSAMR
GROUP BY STATE, MNTH, MR3PROD
UNION ALL
SELECT STATE, MNTH, 'MR-5-01-'||MR2PROD PROD, MR2PROD,
       NULL NUM, COUNT(*) DENOM, NULL RES,
       NULL INUM, NULL IDEN, NULL IRES
FROM JPSAMR
GROUP BY STATE, MNTH, MR2PROD
ORDER BY 1,3
;



--CLEC SPECIFIC  
SELECT STATE, CLEC_ID, MNTH, 'MR-2-01-'||MR2PROD PROD, MR2PROD,
       SUM(CNT) NUM, NULL DEN, NULL RES, 
       NULL INUM, NULL IDEN, NULL IRES
FROM JPSAMR
GROUP BY STATE, CLEC_ID, MNTH, MR2PROD
UNION ALL
SELECT STATE, CLEC_ID, MNTH, 'MR-3-01-'||MR3PROD PROD, MR3PROD,
       SUM(MISS) NUM, COUNT(*) DENOM, ROUND((SUM(MISS)/COUNT(*))*100,2) RES,
       NULL INUM, NULL IDEN, NULL IRES
FROM JPSAMR
GROUP BY STATE, CLEC_ID, MNTH, MR3PROD
UNION ALL
SELECT STATE, CLEC_ID, MNTH, 'MR-4-01-'||MR3PROD PROD, MR3PROD,
       SUM(TTR) NUM, COUNT(*) DENOM, ROUND(SUM(TTR)/COUNT(*),2) RES,
       NULL INUM, NULL IDEN, NULL IRES
FROM JPSAMR
GROUP BY STATE, CLEC_ID, MNTH, MR3PROD
UNION ALL
SELECT STATE, CLEC_ID, MNTH, 'MR-5-01-'||MR2PROD PROD, MR2PROD,
       NULL NUM, COUNT(*) DENOM, NULL RES,
       NULL INUM, NULL IDEN, NULL IRES
FROM JPSAMR
GROUP BY STATE, CLEC_ID, MNTH, MR2PROD
ORDER BY 1,2,4
;





