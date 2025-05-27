SELECT PON, DOCNO, ACNA, ACT, CIRCUIT, DREC, DD, CDDD, TRUNC(DD_COMP) DD_COMP, STATE,  
       --CASE WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
        --    WHEN STATE IN ('IN','AL','FL','GA','MS','TN') THEN 'MIDWEST'
        --  WHEN STATE IN ('NY','PA','CT') THEN 'EAST'
        --    WHEN STATE IN ('IL','OH','WV','MD','VA') THEN 'MID-ATLANTIC'
        --    WHEN STATE IN ('CA','OR','WA','ID','MT') THEN 'WEST'
        --    WHEN STATE IN ('AZ','NM','NV','UT','MN','SC','NC','IA','NE') THEN 'NATIONAL'
        --    ELSE 'Unknown' END REGION,
       CASE WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
	        WHEN STATE IN ('NY','PA','CT','OH','WV') THEN 'EAST'
            WHEN STATE IN ('IN','KY','AL','GA','MS','TN') THEN 'MID-SOUTH'
       		WHEN STATE IN ('ID','MT','IL','MN','IA','NE','UT') THEN 'NATIONAL'
			WHEN STATE IN ('AZ','NV','NM','TX') THEN 'SOUTH'
            WHEN STATE IN ('FL','NC','SC') THEN 'SOUTHEAST'
	  		WHEN STATE IN ('CA','OR','WA') THEN 'WEST'
	  	    ELSE 'Unknown' END REGION,         
       ICSC, TASK_AT_READY,  
       CASE WHEN NC = 'HC' THEN 'DS1'
            ELSE 'DS3' END PRODUCT,
       PROJECT, NULL "CODED", NULL "ISD", NULL "UPDATES"   
FROM (
--           
SELECT sr.document_number docno,
       asr.access_provider_serv_ctr_code ICSC, 
       sr.acna,
       asr.activity_indicator AS act, sr.pon,
       c.exchange_carrier_circuit_id CIRCUIT,
       asr.project_identification PROJECT,
       CASE WHEN SALI.state IS NOT NULL THEN substr(SALI.state,1,2)
            WHEN NL2.CLLI_CODE IS NOT NULL THEN SUBSTR (nl2.clli_code, 5, 2)
            ELSE SUBSTR (nl.clli_code, 5, 2) END STATE,
       asr.connecting_facility_assignment CFA,    
       asr.network_channel_service_code NC,
       TO_DATE (asr.date_time_sent) DREC,
       asr.desired_due_date  DD,  
       aud.CRDD CDDD, 
       t2.task_type TASK_AT_READY,
       asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) DD_COMP        
  FROM task t, 
       access_service_request asr,
       serv_req sr,
       circuit c,
       network_location nl,
       network_location nl2,
       asap.service_request_circuit src,
       asr_user_data aud,
       data_ext.asr_sali sali,
       task t2
 WHERE sr.document_number = asr.document_number
   and sr.document_number = aud.document_number (+)
   and sr.document_number = src.document_number
   AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+)
   AND C.LOCATION_ID = NL.LOCATION_ID (+)
   AND C.LOCATION_ID_2 = NL2.LOCATION_ID (+)
   AND sr.document_number = t.document_number
   AND sr.document_number = t2.document_number (+)
   and sr.document_number = sali.document_number (+)
   --AND T.ACTUAL_COMPLETION_DATE IS NULL
   AND T2.TASK_STATUS (+) = 'Ready'
   AND (sr.supplement_type <> 1 OR sr.supplement_type IS NULL)
   and asr.project_identification = 'SPUNE1ATX9520001'             
   AND t.task_type = 'DD'
   and asr.activity_indicator in ('N','C','T')
)

ORDER BY DD_COMP, DD, DOCNO, CIRCUIT;
