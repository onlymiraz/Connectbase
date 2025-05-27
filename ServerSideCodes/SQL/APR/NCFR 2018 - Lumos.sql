--pull orders from MSSPRE  

SELECT DOCUMENT_NUMBER, PON, ACT_IND, DREC, DD, DDD,  
         CASE WHEN DD_TASK_COMP IS NULL AND ACCEPT_DT > DREC THEN ACCEPT_DT
	        WHEN ACCEPT_DT IS NULL THEN DD_TASK_COMP
	        WHEN ACCEPT_DT <= DD_TASK_COMP AND ACCEPT_DT > DREC THEN ACCEPT_DT 
	        ELSE DD_TASK_COMP END COMP_DT, 
         DD_TASK_COMP, NPA||NXX NPANXX, CLLIZ CLLI, ICSC, ACNA, 
		 CASE WHEN ACNA IN ('FET','FWN') THEN 'LUMOS'
		   ELSE NULL END CUSTOMER,					
         CASE WHEN STATE1 IS NOT NULL THEN STATE1
              WHEN SEC_STATE IS NOT NULL THEN SEC_STATE
              WHEN PRI_STATE IS NOT NULL THEN PRI_STATE
              WHEN ICSC = 'FV01' THEN 'WV'
              WHEN ICSC = 'RT01' THEN 'NY'
              WHEN ICSC = 'SN01' THEN 'CT'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '83' THEN 'ID'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '85' THEN 'OR'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '86' THEN 'WA'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '30' THEN 'IL'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '61' THEN 'NC'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '62' THEN 'SC'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '31' THEN 'IN'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '33' THEN 'MI'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '36' THEN 'OH'
              WHEN SUBSTR(ICSC,1,2) = 'FV' AND SUBSTR(CKT,1,2) = '39' THEN 'WI'
              WHEN ICSC IN ('GT10','GT11') AND SUBSTR(CKT,1,2) IN ('81','45') THEN 'CA'
              WHEN ICSC IN ('GT10','GT11') AND SUBSTR(CKT,1,2) IN ('69','65') THEN 'FL'
              WHEN ICSC IN ('GT10','GT11') AND SUBSTR(CKT,1,2) IN ('12','13') THEN 'TX'
              WHEN SUBSTR(PROJ,1,7) = 'ATTMOB-' THEN SUBSTR(PROJ,12,2)
              ELSE NULL END STATE, 
         CASE WHEN (SUBSTR(RATE_CODE,1,2) = 'OC' OR SUBSTR(NC,1,1) = 'O') THEN 'OCN'
              WHEN (NC = 'HC' OR SUBSTR(CKT,4,2) = 'HC') THEN 'DS1'
              WHEN (NC = 'HF' OR SUBSTR(CKT,4,2) = 'HF') THEN 'DS3'
              WHEN SUBSTR(CKT,7,2) = 'T1' THEN 'DS1'
              WHEN SUBSTR(CKT,7,2) = 'T3' THEN 'DS3'
              WHEN SUBSTR(NC,1,1) IN ('L','X') THEN 'DS0'
              WHEN SUBSTR(CKT,4,1) IN ('L','X') THEN 'DS0'
              WHEN SUBSTR(CKT,4,2) IN ('OS','FX','UC','UG','CL') THEN 'DS0'
              WHEN SUBSTR(CKT,4,2) IN ('YG','QG','DH','YB') THEN 'DS0'
              WHEN (SUBSTR(NC,1,1) = 'K' OR SUBSTR(CKT,4,1) = 'K') THEN 'ETHERNET-UNI'
              WHEN NC = 'SN' THEN 'ETHERNET_NNI'
              WHEN SUBSTR(CKT,4,1) = 'V' THEN 'ETHERNET-EVC'
			  WHEN SUBSTR(PROJ,1,10) = 'ATTMOB-TLS' THEN 'ETHERNET-UNI'
			  WHEN SUBSTR(PROJ,1,10) = 'ATTMOB-EVC' THEN 'ETHERNET-EVC'
              ELSE RATE_CODE END PRODUCT,
         CKT
FROM
(
SELECT SR.PON,
  SR.DOCUMENT_NUMBER,
  ASR.REQUEST_TYPE,
  CASE WHEN NL1.CLLI_CODE IS NOT NULL THEN SUBSTR(NL1.CLLI_CODE,5,2)
       WHEN NL2.CLLI_CODE IS NOT NULL THEN SUBSTR(NL2.CLLI_CODE,5,2)
       ELSE NULL END STATE1,
  MAX(SR.ACTIVITY_IND) keep (dense_rank last order by asr.last_modified_date) ACT_IND,
  MAX(SR.SUPPLEMENT_TYPE) keep (dense_rank last order by asr.last_modified_date) SUPP_TYPE,
  MAX(ASR2.DATE_TIME_SENT) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) DREC, 
  MAX(ASR.DESIRED_DUE_DATE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) DD, 
  MAX(AUD.CRDD) KEEP (DENSE_RANK LAST ORDER BY AUD.LAST_MODIFIED_DATE) DDD, 
  MIN(ACCEPTANCE_DATE) KEEP (DENSE_RANK LAST ORDER BY AUD.LAST_MODIFIED_DATE) ACCEPT_DT, 
  MAX(TRUNC(ASAP.PKG_GMT.SF_GMT_AS_PASSED_TIMEZONE(T.ACTUAL_COMPLETION_DATE,1222))) keep (dense_rank last order by T.last_modified_date) DD_TASK_COMP,
  MAX(ASR.ACCESS_PROVIDER_SERV_CTR_CODE) keep (dense_rank last order by asr.last_modified_date) ICSC,
  MAX(SR.PROJECT_IDENTIFICATION) keep (dense_rank last order by asr.last_modified_date) PROJ,
  MAX(SR.ACNA) keep (dense_rank last order by sr.last_modified_date) ACNA,
  MAX(PRILOC_STATE) keep (dense_rank last order by dlr.last_modified_date) PRI_STATE,
  MAX(SECLOC_STATE) keep (dense_rank last order by dlr.last_modified_date) SEC_STATE,
  MAX(CIR.RATE_CODE) keep (dense_rank last order by cir.last_modified_date) RATE_CODE,
  MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) keep (dense_rank last order by asr.last_modified_date) NC,
  MAX(JEOPARDY_REASON_CODE) KEEP (DENSE_RANK LAST ORDER BY JEOP.LAST_MODIFIED_DATE) JEOP,
  CIR.EXCHANGE_CARRIER_CIRCUIT_ID CKT,
  MAX(ASR.NPA) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NPA,
  MAX(ASR.NXX) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NXX,
  MAX(SUBSTR(NL2.CLLI_CODE,1,6)) KEEP (DENSE_RANK LAST ORDER BY NL2.LAST_MODIFIED_DATE) CLLIZ 
--
FROM SERV_REQ SR, 
     ACCESS_SERVICE_REQUEST ASR,
	 ACCESS_SERVICE_REQUEST ASR2,
	 ASR_USER_DATA AUD,
     NETWORK_LOCATION NL1,
     NETWORK_LOCATION NL2,
     CIRCUIT CIR,
     DESIGN_LAYOUT_REPORT DLR, 
     TASK T,
	 TASK_JEOPARDY_WHYMISS JEOP,
     ASAP.SERVICE_REQUEST_CIRCUIT SRC
--
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = ASR2.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = SRC.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)
AND SRC.CIRCUIT_DESIGN_ID = CIR.CIRCUIT_DESIGN_ID (+)
AND CIR.LOCATION_ID = NL1.LOCATION_ID (+)
AND CIR.LOCATION_ID_2 = NL2.LOCATION_ID (+)
AND SR.DOCUMENT_NUMBER = DLR.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = T.DOCUMENT_NUMBER (+)
AND T.TASK_NUMBER = JEOP.TASK_NUMBER(+)
AND SR.TYPE_OF_SR = 'ASR'
AND T.TASK_TYPE = 'DD'
AND ASR.REQUEST_TYPE IN ('S','E')
AND ASR.ACTIVITY_INDICATOR IN ('N','C')
AND JEOP.JEOPARDY_TYPE_CD(+) = 'W' 
AND SR.DOCUMENT_NUMBER > '1000000'
AND TO_CHAR(T.ACTUAL_COMPLETION_DATE,'YYYYMM') = ('202311')   
--
GROUP BY SR.DOCUMENT_NUMBER,
  SR.PON,
  SR.TYPE_OF_SR, 
  ASR.REQUEST_TYPE, 
  CIR.EXCHANGE_CARRIER_CIRCUIT_ID,
  NL1.CLLI_CODE,
  NL2.CLLI_CODE 
)
--
WHERE (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)
 AND acna in ('FET','FWN');



--pull troubles from CPDWHPRD  

select ckt_id, product, create_date, cleared_dt, closed_dt, ttr, repair_code, disp, ticket_id
from (
select distinct ckt_id, product, create_date, cleared_dt, closed_dt, ttr, repair_code,		
	   case when disp3 is not null then disp3
	        when disp is not null then disp
	        else disp2 end disp, 
       ticket_id
from (
select distinct ticket_id, 
       case when acna is not null then acna
	        when acna1 is not null then acna1
	        when ccna1 is not null then ccna1
			when acna2 is not null then acna2
            else ccna2 end CLEC_ID, 		
       ckt_id,  
	   case when service_type_code = 'HC' then 'DS1'
			when service_type_code = 'HF' then 'DS3'
	   	 	when substr(circuit,4,5) like '%T1%' then 'DS1'
			when substr(circuit,4,5) like '%T3%' then 'DS3'
			when substr(circuit,1,4) like '%HC%' then 'DS1'
			when substr(circuit,1,4) like '%HF%' then 'DS3'
			when substr(circuit,1,2) = 'R2' then 'Ethernet'
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'
			when substr(circuit,3,1) in ('X','L') then 'DS0'
			when substr(service_type_code,1,2) = 'OC' then 'OCN'
			when substr(circuit,1,8) like '%OC%' then 'OCN'
			when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
			else ' ' end product,
	   create_date, 
	   case when Cleared_Dt is not null then Cleared_dt
            else Closed_dt end Cleared_Dt, 
	   case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,
       Total_Duration, 
	   TTR,
	   b.trbl_found_number, b.trbl_found_desc, b.disp, c.trbl_found_number trbl_found_number2, c.trbl_found_desc trbl_found_desc2, c.disp disp2, d.disp disp3,
	   site_id, a.repair_code, serv_code
from (
select a.fld_requestid ticket_id, 
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
	   a.exchange_carrier_circuit_id ckt_id, 
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
	   max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,
	   max(d.acna) keep (dense_rank first order by d.acna) acna2, 
	   max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
	   max(round(a.h_fld_totalopentime_secs_/3600,2)) keep (dense_rank last order by a.fld_modifieddate) Total_Duration,
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
	   max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,  
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
	   MAX(E.SERVICE_TYPE_CODE) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) SERV_CODE,
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
       max(a.fld_assignmentprofile) keep (dense_rank last order by a.fld_modifieddate) profile
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF','FTW TSC','CTF TSC')
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (e.type <> 'T' or type is null) 
and (to_char(dte_closeddatetime,'yyyymm') in ('202311','202312')    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') in ('202311','202312')))   --NEED TO CHANGE THIS EACH MONTH
 --AND d.ISSUE_STATUS = '2'
 and e.status (+) = '6'
group by a.fld_requestid, a.exchange_carrier_circuit_id 
) a, trbl_found_remedy b, repair_code c, trbl_found_remedy d
where a.trbl_found_cd = b.trbl_found_number (+)
and a.repair_code = c.repair_code (+)
and a.repair_code = d.trbl_found_desc (+)   
and (request_type in ('Agent','Alarm','Customer','Maintenance')
  or profile in ('FTW TSC','CTF TSC'))
and substr(ckt_id,4,2) not in ('VM','EM','IP','IB','FX','YB','YG','UG','UH','RT','PL','LA','LU','XA','LA','LO','LN','LU','FD','US','CS')
and reqstat = 'Closed' 
)
where clec_id in ('FET','FWN')	
)				
where disp in ('CO','FAC')				
order by 1,3;	