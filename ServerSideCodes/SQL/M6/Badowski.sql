

SELECT TSK.DOCUMENT_NUMBER, 
       max(ASR.PON) keep (dense_rank last order by asr.last_modified_date) PON, 
	   ASR.ACTIVITY_INDICATOR, 
	   max(SR.CCNA_NAME) keep (dense_rank last order by sr.last_modified_date) NAME,  
	   SR.CCNA,
	   max(SUBSTR(NL.CLLI_CODE,5,2)) keep (dense_rank last order by nl.last_modified_date) STATE, 
	   CASE max(ASR.NETWORK_CHANNEL_SERVICE_CODE) keep (dense_rank last order by asr.last_modified_date)
         when 'HC' then 'DS1'
         when 'HF' then 'DS3'
         when 'KD' then 'TLS/Optical'
         when 'KE' then 'TLS/Optical'
         when 'KF' then 'Optical'
         when 'KQ' then 'TLS/Optical'
         when 'KR' then 'Optical'
         when 'LD' then 'DS0'
         when 'LG' then 'DS0'
         when 'OB' then 'SONET/Optical'
         when 'SD' then 'Switched Facility'
         when 'SH' then 'Switched Facility'
         when 'UC' then 'DS0'
         when 'XD' then 'DS0'
         when 'XG' then 'DS0'
         when 'XH' then 'DS0'
         else 'OTHER' end Serivce_code,
	   max(ASR.NETWORK_CHANNEL_SERVICE_CODE) keep (dense_rank last order by asr.last_modified_date) NC,	  
	   max(TSK.ACTUAL_COMPLETION_DATE) keep (dense_rank last order by asr.last_modified_date) Actual_Comp_DT, 
	   TSK.TASK_STATUS, 
	   max(ASR.DESIRED_DUE_DATE) keep (dense_rank last order by asr.last_modified_date) Due_Date  
FROM CASDW.TASK TSK, CASDW.ACCESS_SERVICE_REQUEST ASR, CASDW.SERV_REQ SR, CASDW.NETWORK_LOCATION NL
WHERE ASR.DOCUMENT_NUMBER=TSK.DOCUMENT_NUMBER 
AND SR.DOCUMENT_NUMBER=TSK.DOCUMENT_NUMBER 
AND ASR.LOCATION_ID = NL.LOCATION_ID(+) 
AND NOT ASR.ACCESS_PROVIDER_SERV_CTR_CODE IS NULL 
AND SR.CCNA<>'CUS' 
AND TSK.TASK_STATUS IN ('Complete', 'Pending', 'Ready') 
AND TSK.TASK_TYPE='DD' 
AND (ASR.SUPPLEMENT_TYPE<>'1' OR ASR.SUPPLEMENT_TYPE IS NULL) 
AND ASR.ACTIVITY_INDICATOR IN ('D', 'N') 
AND ASR.ORDER_TYPE='ASR' 
AND (TO_CHAR(TSK.ACTUAL_COMPLETION_DATE, 'YYYYMM') >= '201201' OR TSK.ACTUAL_COMPLETION_DATE IS NULL)
GROUP BY TSK.DOCUMENT_NUMBER, ASR.ACTIVITY_INDICATOR, SR.CCNA, TSK.TASK_STATUS
ORDER BY 7,9
