select DOCNO, PON, ACNA, ICSC, STATE, D_REC, APP_COMP_DT, DD, DDD, Accept_dt, DD_COMP_DT, NC, SPEC, request_type, ACT, expedite, task_at_ready, work_queue_id
FROM (
SELECT PON, DOCUMENT_NUMBER DOCNO, ACNA, ACT, CKT, D_REC, DD, DDD, accept_dt, dd_comp_dt, 	
	   ICSC, 
       CASE when clliz in ('NY','PA','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA') then clliz
	        when cllia in ('NY','PA','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA') then cllia
			when state in ('NY','PA','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA') then state
			when cfastate in ('NY','PA','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA') then cfastate
	        when pot in ('NY','PA','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA') then pot
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
			when icsc in ('RT01','NY01') then 'NY'
			when icsc in ('IB94') then 'IL'
			ELSE null END STATE,
	   NC, spec, request_type, expedite, app_comp_dt, task_at_ready, work_queue_id
FROM
(
select a.acna, a.pon, a.document_number, icsc, a.request_type, d_rec, dd, ddd, accept_dt, dd_comp_dt,
       nc, spec, act, app_comp_dt, supp, ckt, expedite, a.npa, a.nxx, lata, task_at_ready, work_queue_id,
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code, 
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) cllia,
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl2.last_modified_date) clliz,
	   substr(cfa,24,2) cfastate,
	   substr(pot,5,2) pot, 
	   npa.state
from (
SELECT distinct max(sr.acna) keep (dense_rank last order by sr.last_modified_date) acna,
       max(sr.pon) keep (dense_rank last order by sr.last_modified_date) pon,
       sr.document_number,
	   max(asr.access_provider_serv_ctr_code) keep (dense_rank last order by asr.last_modified_date) icsc, 
       max(asr.request_type) keep (dense_rank last order by asr.last_modified_date) request_type,  
       max(asr.date_received) keep (dense_rank last order by asr.last_modified_date) d_rec, 
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 
	   min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
	   trunc(t2.actual_completion_date-5/24) DD_COMP_DT,
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 
	   max(asr.SERVICE_AND_PRODUCT_ENHANC_COD) keep (dense_rank last order by asr.last_modified_date) spec,  
	   max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
	   max(trunc(t1.actual_completion_date-5/24)) keep (dense_rank last order by t1.last_modified_date) APP_COMP_DT,
	   max(asr.connecting_facility_assignment) keep (dense_rank last order by asr.last_modified_date) cfa,
	   max(asr.additional_point_of_term) keep (dense_rank last order by asr.last_modified_date) pot,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
	   max(expedite_indicator) keep (dense_rank last order by asr.last_modified_date) expedite,
	   max(npa) keep (dense_rank last order by asr.last_modified_date) npa,
	   max(nxx) keep (dense_rank last order by asr.last_modified_date) nxx,
	   max(lata_number) keep (dense_rank last order by asr.last_modified_date) lata,
	   t3.task_type task_at_ready, 
	   t3.work_queue_id 
--
FROM casdw.SERV_REQ SR, 
     casdw.ACCESS_SERVICE_REQUEST ASR,
	 CASDW.ASR_USER_DATA AUD,
	 casdw.TASK T1,
	 casdw.TASK T2,
	 casdw.TASK T3
--
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = T1.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = T2.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = T3.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)
--AND SR.TYPE_OF_SR in ('ASR')
and asr.activity_indicator not in ('D','R')
AND T1.TASK_TYPE = 'APP'
AND T2.TASK_TYPE = 'DD'
and t2.actual_completion_date is null
and t3.task_status = 'Ready'
and sr.document_number not in ('1260995','1201299') --,'1333343')
and sr.ccna = 'CUS' 
--
GROUP BY SR.DOCUMENT_NUMBER, t2.actual_completion_date, --t1.scheduled_completion_date, t1.actual_completion_date, t1.revised_completion_date, 
         t3.task_type, t3.work_queue_id 
) a,
  casdw.NETWORK_LOCATION NL1,
  casdw.NETWORK_LOCATION NL2,
  casdw.CIRCUIT CIR,
  casdw.DESIGN_LAYOUT_REPORT DLR,
  npanxx npa
  --
where A.DOCUMENT_NUMBER = DLR.DOCUMENT_NUMBER (+)  
AND A.CKT = CIR.EXCHANGE_CARRIER_CIRCUIT_ID (+) 
AND CIR.LOCATION_ID = NL1.LOCATION_ID (+)
AND CIR.LOCATION_ID_2 = NL2.LOCATION_ID (+)
AND A.NPA||A.NXX = NPA.NPANXX (+)
AND (SUPP <> '1' OR SUPP IS NULL)
and dd_comp_dt is null
group by a.acna, a.pon, a.document_number, icsc, a.request_type, d_rec, dd, ddd, accept_dt, dd_comp_dt,
         nc, spec, act, app_comp_dt, supp, ckt, expedite, a.npa, a.nxx, lata, task_at_ready, work_queue_id, npa.state, cfa, pot
))
order by 8		 




select * from casdw.task
where document_number = '1497825'