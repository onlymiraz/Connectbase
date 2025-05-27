select distinct DOCNO, PON, ACNA, CARRIER, PROD, DD, STATE, SPEC
FROM (
SELECT DOCNO, PON, DD, ACNA,
      (CASE when acna in ('ATX','VMS') then 'ATT Communications'
		    when acna in ('DTC','PUL','GMT','UNV','EBA','PTM') then 'Verizon Wireless'
			when acna in ('BAX','MCI','WTL','MPL','TQW','GOP') then 'Verizon Business' -- Includes XO 
			when acna in ('VAU','UHC','PUA','CPO','NGE','HOC','IOR') then 'Windstream'  --includes Earthlink 
			when acna in ('IUW','AWL') then 'ATT Mobility'
			when acna in ('WCG','OPT') then 'T-Mobile'
			when acna in ('TFU','NVE') then 'TPX'
            when acna in ('LGT','CAL','LTL','FLS','LVC','TIM','NNL','PUN') then 'Lumen'   --includes Level 3 
            when acna in ('BPH','COJ','JCV','JNC','OMD','OMQ') then 'Comcast'
			when acna = 'UTC' then 'Sprint'
			when acna = 'MJC' then 'Sprint PCS'
			when acna = 'NHZ' then 'New Horizon Communications'
			when acna in ('OVC','UVA') then 'Global Capacity'
			when acna = 'NKV' then 'Nitel'
			when acna = 'MPJ' then 'MP Communications'
			when acna = 'GBW' then 'Global Telecom & Tech'
			when acna = 'IRZ' then 'Airespring'
			when acna = 'GIM' then 'Granite'
            when acna = 'RVF' then 'US Signal'
            when acna = 'AFE' then 'Spectrotel'
            when acna = 'MTV' then 'MetTel'
            when acna = 'IGP' then 'BCN Telecom'
            when acna = 'QCF' then 'CFN Services'
            when acna = 'VNH' then 'Charter'
	        else 'OTHER' end) as Carrier, 
       CASE when state is not null then state
            when (npastate is not null and npastate <> 'LE') then npastate
	        when clliz is not null then clliz
			when cllia is not null then cllia
	        when icsc = 'FV01' then 'WV'
			when icsc = 'SN01' then 'CT'
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
            when substr(icsc,1,4) = 'GT10' and substr(ckt,1,2) in ('12','13') then 'TX'
            when substr(icsc,1,4) = 'GT10' and substr(ckt,1,2) in ('69','65') then 'FL'
            when substr(icsc,1,4) = 'GT10' and substr(ckt,1,2) in ('81','45') then 'CA'
			when substr(icsc,1,2) <> 'FV' and substr(ckt,1,2) = '61' then 'PA'
			when substr(ckt,1,2) = '23' then 'MN'
			when substr(ckt,1,2) = '50' then 'WV'
			when substr(ckt,1,2) = '11' then 'AZ'
			when substr(ckt,1,2) = '97' then 'NY'
			when icsc = 'RT01' then 'NY'
			ELSE null END STATE,
	   case when nc = 'HC' then 'DS1'
	        when nc = 'HF' then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
			when nc in ('OB','OD','OF','OG') then 'OCN'
            WHEN SUBSTR(NC,1,2) in ('SN') then 'Ethernet-NNI' 
            WHEN SUBSTR(NC,1,1) in ('K') AND ACTL IS NOT NULL AND EUNAME IS NULL AND SPEC <> 'GGAMAN' THEN 'Ethernet-NNI'
			when substr(nc,1,1) in ('K') then 'Ethernet-UNI'
			when substr(nc,1,1) in ('V') then 'Ethernet-EVC'
            when substr(nc,1,2) in ('SN') then 'Ethernet-NNI'
			when substr(ckt,4,1) in ('K') then 'Ethernet-UNI'
			when substr(ckt,4,1) in ('V') then 'Ethernet-EVC'
			when acna = 'MJC' and pon like '%-E%' then 'Ethernet-EVC'
			when proj like 'ATTMOB-%' then 'Ethernet'
			else ' ' end Prod, SPEC		
FROM
(
SELECT SR.DOCUMENT_NUMBER DOCNO, SR.PON,
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
  max(asr.service_and_product_enhanc_cod) keep (dense_rank last order by asr.last_modified_date) SPEC,
  det.actl, SALI.EUNAME,
  substr(npa.exchange_area_clli,5,2) npastate,
  --max(secloc_state) sec, 
  --max(priloc_state) pri,
  substr(SALI.STATE,1,2) state
--
FROM SERV_REQ SR, 
     ACCESS_SERVICE_REQUEST ASR, 
	 NETWORK_LOCATION NL1,
	 NETWORK_LOCATION NL2,
	 CIRCUIT CIR,
	 --DESIGN_LAYOUT_REPORT DLR, 
	 TASK TSK,
	 ASR_USER_DATA AUD,
	 data_ext.asr_sali SALI,
     data_ext.asr_detail det,
     npa_nxx npa
--
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)
--AND SR.DOCUMENT_NUMBER = DLR.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)
--AND DLR.CIRCUIT_DESIGN_ID = CIR.CIRCUIT_DESIGN_ID (+)
AND sr.first_ecckt_id = CIR.exchange_carrier_circuit_id (+)
AND CIR.LOCATION_ID = NL1.LOCATION_ID (+)
AND CIR.LOCATION_ID_2 = NL2.LOCATION_ID (+)
and SR.DOCUMENT_NUMBER = SALI.DOCUMENT_NUMBER(+)
and sr.document_number = det.document_number (+)
and asr.npa = npa.npa (+)
and asr.nxx = npa.nxx (+)
AND SR.TYPE_OF_SR in ('ASR')
and asr.request_type in ('S','E')
and asr.activity_indicator in ('N','C')
AND TSK.TASK_TYPE = 'DD'
and tsk.actual_completion_date is null
--
GROUP BY SR.DOCUMENT_NUMBER, SR.PON, SALI.STATE, SALI.EUNAME, det.actl, npa.exchange_area_clli 
)
--
WHERE (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)
and (rate_code not in ('DS0','DS1','DS3') or rate_code is null)
and (substr(nc,1,1) not in ('H','L','X') or nc is null)
and (substr(ckt,4,1) not in ('H','L','X') or ckt is null)
and dd_comp is null
and (acna not in ('FLR','ZZZ','CUS','FCA','ZWV','CQV','ZTK','CZX','XYY','FLF') or acna is null)
--and (proj not like 'ATTMOB%' 
--and proj not like 'MPAEVC%'
--or proj is null)
)
where (prod not in ('DS0','DS1','DS3') or prod is null)
 ORDER BY 1
 

 
