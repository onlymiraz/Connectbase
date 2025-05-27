--FOR BACKLOG AND PENDING ORDERS  

SELECT DOCNO, PON, ACNA, ACT, 
       CASE WHEN NC = 'HC' THEN 'DS1'
	        ELSE 'DS3' END PRODUCT,
	   PROJECT, 
	   ADDRESS "STREET ADDRESS", CITY, STATE, 
	   --CASE WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
	     --   WHEN STATE IN ('IN','AL','FL','GA','MS','TN') THEN 'MIDWEST'
       	--	WHEN STATE IN ('NY','PA','CT') THEN 'EAST'
		--	WHEN STATE IN ('IL','OH','WV','MD','VA') THEN 'MID-ATLANTIC'
	  	--	WHEN STATE IN ('CA','OR','WA','ID','MT') THEN 'WEST'
	  	--	WHEN STATE IN ('AZ','NM','NV','UT','MN','SC','NC','IA','NE') THEN 'NATIONAL'
	  	--	ELSE 'Unknown' END REGION,
       CASE WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
	        WHEN STATE IN ('NY','PA','CT','OH','WV') THEN 'EAST'
            WHEN STATE IN ('IN','KY','AL','GA','MS','TN') THEN 'MID-SOUTH'
       		WHEN STATE IN ('ID','MT','IL','MN','IA','NE','UT') THEN 'NATIONAL'
			WHEN STATE IN ('AZ','NV','NM','TX') THEN 'SOUTH'
            WHEN STATE IN ('FL','NC','SC') THEN 'SOUTHEAST'
	  		WHEN STATE IN ('CA','OR','WA') THEN 'WEST'
	  	    ELSE 'Unknown' END REGION,     
	   CIRCUIT, CFA, DATE_RCVD, CDDD, DD 
FROM (
--	   	
SELECT sr.document_number docno,
       asr.access_provider_serv_ctr_code ICSC, 
	   sr.acna,
       asr.activity_indicator AS act, sr.pon,
       c.exchange_carrier_circuit_id CIRCUIT,
       asr.project_identification PROJECT,
	   SANO||' '||SASD||' '||SASN||' '||SATH ADDRESS, SALI.CITY,
	   CASE WHEN SALI.state IS NOT NULL THEN substr(SALI.state,1,2)
	        WHEN NL2.CLLI_CODE IS NOT NULL THEN SUBSTR (nl2.clli_code, 5, 2)
			ELSE SUBSTR (nl.clli_code, 5, 2) END STATE,
       asr.connecting_facility_assignment CFA,    
       asr.network_channel_service_code NC,
       TO_DATE (asr.date_received) DATE_RCVD,
       asr.desired_due_date  DD,  
	   aud.CRDD CDDD,  
	   case when asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) IS NULL AND ACCEPTANCE_DATE > DATE_TIME_SENT 
	             THEN ACCEPTANCE_DATE
	        WHEN ACCEPTANCE_DATE IS NULL AND asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) IS NOT NULL 
			     THEN asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222)
	        WHEN ACCEPTANCE_DATE <= asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) AND ACCEPTANCE_DATE > DATE_TIME_SENT 
			     THEN ACCEPTANCE_DATE
			WHEN asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) <= ACCEPTANCE_DATE 
			     THEN asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) 
	        ELSE NULL END COMPLETION_DT	     
  FROM task t, 
       access_service_request asr,
       serv_req sr,
       circuit c,
       network_location nl,
	   network_location nl2,
       asap.service_request_circuit src,
       asr_user_data aud,
	   data_ext.asr_sali sali
 WHERE sr.document_number = asr.document_number
   and sr.document_number = aud.document_number
   and sr.document_number = src.document_number
   AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+)
   AND C.LOCATION_ID = NL.LOCATION_ID (+)
   AND C.LOCATION_ID_2 = NL2.LOCATION_ID (+)
   AND sr.document_number = t.document_number
   and sr.document_number = sali.document_number (+)
   AND (T.ACTUAL_COMPLETION_DATE IS NULL
     OR to_char(T.ACTUAL_COMPLETION_DATE,'yyyy') = '2016')
   AND (sr.supplement_type <> 1 OR sr.supplement_type IS NULL)
   and sr.ccna IN ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH',
                   'AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN','BSM','CBL','CCB','CDA','CEO','CEU',
			       'CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO','CSU','CSX','CTJ','CUO','CUY','CZB',
			       'DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','IMP','IND',
				   'ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA','MCC','MCE','MCQ','MCV','MCW','MCZ',
			       'MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV',
				   'OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN','SCU','SHI','SLL','SMC','SNP','STH',
				   'SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC') 			
   AND t.task_type = 'DD'
   and asr.network_channel_service_code in ('HC','HF')
   and asr.activity_indicator in ('N')
)
-- 
WHERE COMPLETION_DT IS NULL 
and (substr(project,3,2) in ('AM') 
     or docno = '2297694'
     or project like '%UMTS%')
ORDER BY DD, DOCNO, CIRCUIT;
   
   
   
--FOR ALL ORDER HISTORY    

SELECT DOCNO, PON, ACNA, ACT, 
       CASE WHEN NC = 'HC' THEN 'DS1'
	        ELSE 'DS3' END PRODUCT,
	   PROJECT, CIRCUIT, CFA, 
	   CASE WHEN COMPLETION_DT IS NULL THEN 'PENDING' ELSE 'COMPLETED' END STATUS, 
	   DATE_RCVD, CDDD, DD, COMPLETION_DT,
	   ADDRESS "STREET ADDRESS", CITY, STATE, 
	   --CASE WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
	     --   WHEN STATE IN ('IN','AL','FL','GA','MS','TN') THEN 'MIDWEST'
       	--	WHEN STATE IN ('NY','PA','CT') THEN 'EAST'
		--	WHEN STATE IN ('IL','OH','WV','MD','VA') THEN 'MID-ATLANTIC'
	  	--	WHEN STATE IN ('CA','OR','WA','ID','MT') THEN 'WEST'
	  	--	WHEN STATE IN ('AZ','NM','NV','UT','MN','SC','NC','IA','NE') THEN 'NATIONAL'
	  	--	ELSE 'UNKNOWN' END REGION
       CASE WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
	        WHEN STATE IN ('NY','PA','CT','OH','WV') THEN 'EAST'
            WHEN STATE IN ('IN','KY','AL','GA','MS','TN') THEN 'MID-SOUTH'
       		WHEN STATE IN ('ID','MT','IL','MN','IA','NE','UT') THEN 'NATIONAL'
			WHEN STATE IN ('AZ','NV','NM','TX') THEN 'SOUTH'
            WHEN STATE IN ('FL','NC','SC') THEN 'SOUTHEAST'
	  		WHEN STATE IN ('CA','OR','WA') THEN 'WEST'
	  	    ELSE 'Unknown' END REGION     
FROM (
--	   	
SELECT sr.document_number docno,
       asr.access_provider_serv_ctr_code ICSC, 
	   sr.acna,
       asr.activity_indicator AS act, sr.pon,
       c.exchange_carrier_circuit_id CIRCUIT,
       asr.project_identification PROJECT,
	   SANO||' '||SASD||' '||SASN||' '||SATH ADDRESS, SALI.CITY,
	   CASE WHEN SALI.state IS NOT NULL THEN substr(SALI.state,1,2)
	        WHEN NL2.CLLI_CODE IS NOT NULL THEN SUBSTR (nl2.clli_code, 5, 2)
			ELSE SUBSTR (nl.clli_code, 5, 2) END STATE,
       asr.connecting_facility_assignment CFA,    
       asr.network_channel_service_code NC,
       TO_DATE (asr.date_received) DATE_RCVD,
       asr.desired_due_date  DD,  
	   aud.CRDD CDDD, 
	   case when asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) IS NULL AND ACCEPTANCE_DATE > DATE_TIME_SENT 
	             THEN ACCEPTANCE_DATE
	        WHEN ACCEPTANCE_DATE IS NULL AND asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) IS NOT NULL 
			     THEN asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222)
	        WHEN ACCEPTANCE_DATE <= asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) AND ACCEPTANCE_DATE > DATE_TIME_SENT 
			     THEN ACCEPTANCE_DATE
			WHEN asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) <= ACCEPTANCE_DATE 
			     THEN asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) 
	        ELSE NULL END COMPLETION_DT	     
  FROM task t, 
       access_service_request asr,
       serv_req sr,
       circuit c,
       network_location nl,
	   network_location nl2,
       asap.service_request_circuit src,
       asr_user_data aud,
	   data_ext.asr_sali sali
 WHERE sr.document_number = asr.document_number
   and sr.document_number = aud.document_number
   and sr.document_number = src.document_number
   AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+)
   AND C.LOCATION_ID = NL.LOCATION_ID (+)
   AND C.LOCATION_ID_2 = NL2.LOCATION_ID (+)
   AND sr.document_number = t.document_number
   and sr.document_number = sali.document_number (+)
   AND (T.ACTUAL_COMPLETION_DATE IS NULL
     OR to_char(T.ACTUAL_COMPLETION_DATE,'yyyy') = '2016')
   AND (sr.supplement_type <> 1 OR sr.supplement_type IS NULL)
   and sr.ccna IN ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH',
                   'AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN','BSM','CBL','CCB','CDA','CEO','CEU',
			       'CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO','CSU','CSX','CTJ','CUO','CUY','CZB',
			       'DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','IMP','IND',
				   'ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA','MCC','MCE','MCQ','MCV','MCW','MCZ',
			       'MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV',
				   'OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN','SCU','SHI','SLL','SMC','SNP','STH',
				   'SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC') 			
   AND t.task_type = 'DD'
   and asr.network_channel_service_code in ('HC','HF')
   and asr.activity_indicator in ('N')
   and sr.document_number not in ('2190134')
)
-- 
WHERE (substr(project,3,2) in ('AM') 
     or docno = '2297694'
     or project like '%UMTS%')
ORDER BY COMPLETION_DT, DD, DOCNO, CIRCUIT; 