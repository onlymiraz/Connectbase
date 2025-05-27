select PON, DOCNO, ACNA, ACT_IND, CKT, D_REC, DD, DDD, DD_TASK_COMP_DT, ACCEPT_DT, STATE, ICSC, PRODUCT, PROJ
FROM (
SELECT PON, DOCUMENT_NUMBER DOCNO, ACNA, ACT_IND, CKT, TRUNC(D_REC) D_REC, DD, DDD, accept_dt, dd_comp dd_task_comp_dt,  
       CASE when dd_comp is null and accept_dt > d_rec then Accept_dt
	        when Accept_dt is null then dd_comp
	        when Accept_dt <= dd_comp and accept_dt > d_rec then Accept_dt 
	        else dd_comp end Comp_Dt, 	
	   ICSC, 
       CASE when clliz is not null then clliz
	        when cllia is not null then cllia
			when icsc = 'FV01' then 'WV'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '30' then 'IL'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '31' then 'IN'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '33' then 'MI'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '36' then 'OH'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '39' then 'WI'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '43' then 'OR'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '61' then 'NC'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '62' then 'SC'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '83' then 'ID'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '85' then 'OR'
			when substr(icsc,1,2) = 'FV' and substr(ckt,1,2) = '86' then 'WA'
			when substr(icsc,1,2) <> 'FV' and substr(ckt,1,2) = '61' then 'PA'
			when substr(ckt,1,2) = '23' then 'MN'
			when substr(ckt,1,2) = '50' then 'WV'
			when substr(ckt,1,2) = '11' then 'AZ'
			when substr(ckt,1,2) = '97' then 'NY'
			when icsc = 'RT01' then 'NY'
			when pri is not null then pri
			when sec is not null then sec
			ELSE null END STATE,
	   CASE when substr(nc,1,2) in ('HC','T1') then 'DS1'
	        when substr(nc,1,2) in ('HF','T3') then 'DS3'
	   		WHEN SUBSTR(NC,1,1) in ('K','V') then 'Ethernet'
			WHEN SUBSTR(CKT,4,1) in ('K','V') THEN 'Ethernet'
			when proj like 'ATTMOB-%' then 'Ethernet'
			when substr(nc,1,1) = 'O' then 'OCN'
			ELSE NULL END PRODUCT,
	   PROJ, RATE_CODE, NC
FROM
(
SELECT SR.PON,
  SR.DOCUMENT_NUMBER,
  MAX(SUBSTR(NL1.CLLI_CODE,5,2)) keep (dense_rank last order by nl1.last_modified_date) CLLIA,
  MAX(SUBSTR(NL2.CLLI_CODE,5,2)) keep (dense_rank last order by nl2.last_modified_date) CLLIZ,    
  MAX(SR.ACTIVITY_IND) keep (dense_rank last order by sr.last_modified_date) ACT_IND,
  MAX(SR.SUPPLEMENT_TYPE) keep (dense_rank last order by sr.last_modified_date) SUPP_TYPE,
  MAX(SR.FIRST_ECCKT_ID) keep (dense_rank last order by sr.last_modified_date) CKT,
  max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) D_REC, 
  max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
  max(AUD.crdd) keep (dense_rank last order by aud.last_modified_date) DDD,
  MAX(AUD.ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) ACCEPT_DT,
  MAX(TRUNC(TSK.ACTUAL_COMPLETION_DATE)) keep (dense_rank last order by tsk.last_modified_date) DD_COMP,
  MAX(ASR.ACCESS_PROVIDER_SERV_CTR_CODE) keep (dense_rank last order by asr.last_modified_date) ICSC,
  MAX(REPLACE(SR.PROJECT_IDENTIFICATION,' ')) keep (dense_rank last order by sr.last_modified_date) PROJ,
  MAX(SR.ACNA) keep (dense_rank last order by sr.last_modified_date) ACNA,
  MAX(CIR.RATE_CODE) keep (dense_rank last order by cir.last_modified_date) RATE_CODE,
  MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) keep (dense_rank last order by asr.last_modified_date) NC,
  max(CIR.EXCHANGE_CARRIER_CIRCUIT_ID) keep (dense_rank last order by cir.last_modified_date) CIRCKT,
  max(secloc_state) sec, 
  max(priloc_state) pri 
--
FROM casdw.SERV_REQ SR, 
     casdw.ACCESS_SERVICE_REQUEST ASR, 
	 casdw.NETWORK_LOCATION NL1,
	 casdw.NETWORK_LOCATION NL2,
	 casdw.CIRCUIT CIR,
	 casdw.DESIGN_LAYOUT_REPORT DLR, 
	 casdw.TASK TSK,
	 CASDW.ASR_USER_DATA AUD
--
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = DLR.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)
AND DLR.CIRCUIT_DESIGN_ID = CIR.CIRCUIT_DESIGN_ID (+)
AND CIR.LOCATION_ID = NL1.LOCATION_ID (+)
AND CIR.LOCATION_ID_2 = NL2.LOCATION_ID (+)
AND SR.TYPE_OF_SR in ('ASR')
and asr.request_type in ('S','E')
AND TSK.TASK_TYPE = 'DD'
--and (tsk.actual_completion_date is null or to_char(tsk.actual_completion_date,'yyyy') = '2012')
and SR.PROJECT_IDENTIFICATION like 'ATTMPIU%'
--
GROUP BY SR.DOCUMENT_NUMBER,
  SR.PON     
)
--
WHERE (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)
)
 ORDER BY 7,1
 
