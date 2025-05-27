SELECT *
FROM (
--
SELECT ASR.DOCUMENT_NUMBER, 
       ASR.PON, 
       C.EXCHANGE_CARRIER_CIRCUIT_ID CKT, 
       SR.ACNA, 
       ASR.ACTIVITY_INDICATOR ACT, 
       ASR.SUPPLEMENT_TYPE SUPP,                                 
       ASR.DATE_TIME_SENT, 
       ASR.DATE_RECEIVED, 
       ASR.DESIRED_DUE_DATE, 
       AUD.CRDD, 
       AUD.ACCEPTANCE_DATE, 
       T.ACTUAL_COMPLETION_DATE DD_TASK_COMP, 
       T2.TASK_TYPE TASK_AT_READY, 
       ASR.NETWORK_CHANNEL_SERVICE_CODE||ASR.NETWORK_CHANNEL_OPTION_CODE NC,                                  
       SUBSTR(NPA.EXCHANGE_AREA_CLLI,5,2) NPA_STATE, 
       SALI.PI, REPLACE(REPLACE(TRIM(SAPR||' '||SANO||' '||SASF||' '||SASD||' '||SASN||' '||SATH||' '||SASS),'  ',' '),'  ',' ') ADDRESS, 
       SALI.CITY, 
       SUBSTR(SALI.STATE,1,2) SALI_STATE, 
       SALI.ZIP, 
       SALI.EUNAME,  
       CASE WHEN NL.EXCHANGE_AREA_CLLI IS NOT NULL THEN NL.EXCHANGE_AREA_CLLI
            ELSE NL3.EXCHANGE_AREA_CLLI END LSO_LOCATION_A, 
       CASE WHEN NL2.EXCHANGE_AREA_CLLI IS NOT NULL THEN NL2.EXCHANGE_AREA_CLLI
            ELSE NL4.CLLI_CODE END LSO_LOCATION_Z,
       CDD.ACCESS_CUST_TERMINAL_LOCATION ACTL, 
       CDD.CONNECTING_FACILITY_ASSIGNMENT CFA, 
       CDD.MUX_LOCATION, 
       CASE WHEN SANO IS NULL THEN CDD.SECONDARY_LOCATION ELSE NULL END SECLOC,
       ASR.CROSS_CONNECT_EQ_ASSIGN CCEA, 
       ASR.SECONDARY_CONNECT_FAC SCFA, 
       SRSI.SEC_CROSS_CONNECT_EQ_ASSIGN SCCEA                              
FROM ACCESS_SERVICE_REQUEST ASR,                                 
     SERV_REQ SR,                                  
     NPA_NXX NPA,                                 
     SERVICE_REQUEST_CIRCUIT SRC,                                 
     CIRCUIT C,   
     DATA_EXT.CKT_DESIGN_DETAIL CDD,                              
     DATA_EXT.ASR_SALI SALI,                                
     ASR_USER_DATA AUD,
     ASR_SRSI SRSI,                                
     TASK T,                                
     TASK T2,                                
     NETWORK_LOCATION NL,                                
     NETWORK_LOCATION NL2,
     NETWORK_LOCATION NL3,                                
     NETWORK_LOCATION NL4                                                                                  
WHERE ASR.DOCUMENT_NUMBER = SR.DOCUMENT_NUMBER                                 
AND ASR.NPA = NPA.NPA (+)                                
AND ASR.NXX = NPA.NXX (+)                                
AND ASR.DOCUMENT_NUMBER = SRC.DOCUMENT_NUMBER (+)                                
AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+) 
AND C.CIRCUIT_DESIGN_ID = CDD.CIRCUIT_DESIGN_ID (+)                              
AND ASR.DOCUMENT_NUMBER = SALI.DOCUMENT_NUMBER (+)                                
AND ASR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+) 
AND ASR.DOCUMENT_NUMBER = SRSI.DOCUMENT_NUMBER (+)                                
AND ASR.DOCUMENT_NUMBER = T.DOCUMENT_NUMBER (+)                                
AND ASR.DOCUMENT_NUMBER = T2.DOCUMENT_NUMBER (+)                                
AND CDD.LOCATION_ID_LSO_A = NL.LOCATION_ID (+)                                
AND CDD.LOCATION_ID_LSO_Z = NL2.LOCATION_ID (+)  
AND C.LOCATION_ID = NL3.LOCATION_ID (+)                                
AND C.LOCATION_ID_2 = NL4.LOCATION_ID (+)                              
AND ASR.ACTIVITY_INDICATOR = 'N'                                
AND T.TASK_TYPE = 'DD'                                
AND T2.TASK_STATUS (+) = 'Ready' 
AND SRSI.TERM_TYPE_CD (+) = 'SECLOC'                                                           
AND ASR.NETWORK_CHANNEL_SERVICE_CODE IN (                                
    'HF','HC','XA','XB','XG','XC','XH','XD','LC','LF',                                
    'LG','LN','LP','LR','LQ','LB','LD','LE','LH','LJ','LK')                                
AND (ASR.SUPPLEMENT_TYPE <> 1 OR ASR.SUPPLEMENT_TYPE IS NULL) 
AND TO_CHAR(ASR.DATE_TIME_SENT,'YYYYMMDD') >= '20220512'                                
AND SUBSTR(NPA.EXCHANGE_AREA_CLLI,5,2) in ('FL','IN')                               
--
)
WHERE (PI = 'Y' AND SUBSTR(LSO_LOCATION_A,1,8) in ('ALFAFLXA','BRDNFLAX')
   OR PI IS NULL AND SUBSTR(LSO_LOCATION_Z,1,8) in ('ALFAFLXA','BRDNFLAX'))
ORDER BY 1,3;   

                             
