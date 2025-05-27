select distinct document_number docno, pon, acna, icsc, state, drec, dd, ddd, app_sched_date, app_actual_date, app_revised_date,  
       Prod, nc, spec, request_type, act, expedite, task_at_ready, work_queue_id	
from (
select document_number, trunc(d_rec) drec, dd, ddd,  
	   case when nc = 'HC' then 'DS1'
	        when nc = 'HF' then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
			when nc = 'OB' then 'OC3'
			when nc = 'OD' then 'OC12'
			when nc = 'OF' then 'OC48'
			when nc = 'OG' then 'OC192'
			when substr(nc,1,1) in ('K','V') then 'Ethernet'
			when substr(ckt,4,1) in ('K','V') then 'Ethernet'
			when request_type = 'M' then 'Trunk'
			else ' ' end Prod,		
		pon, icsc, acna,  
		case when state in ('NY','PA','CT','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA','TX') then state
			 when cfastate in ('NY','PA','CT','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA','TX') then cfastate
	         when pot in ('NY','PA','CT','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA','TX') then pot
			 else null end state,
		supp, expedite, nc, spec, request_type, act, app_sched_date, app_actual_date, app_revised_date, task_at_ready, work_queue_id
from (
select distinct SR.ACNA,
       SR.PON,
       SR.DOCUMENT_NUMBER,
	   ASR.ACCESS_PROVIDER_SERV_CTR_CODE ICSC, 
       ASR.REQUEST_TYPE,  
       ASR.DATE_RECEIVED D_REC, 
	   ASR.DESIRED_DUE_DATE DD, 
	   AUD.CRDD DDD, 
	   ACCEPTANCE_DATE ACCEPT_DT,
	   ASR.NETWORK_CHANNEL_SERVICE_CODE NC, 
	   ASR.SERVICE_AND_PRODUCT_ENHANC_COD SPEC,  
	   ASR.ACTIVITY_INDICATOR ACT,
	   asr.NPA,
	   asr.NXX,
	   ASR.SUPPLEMENT_TYPE SUPP,
	   SR.FIRST_ECCKT_ID CKT,
	   EXPEDITE_INDICATOR EXPEDITE,
	   substr(npa.exchange_area_clli,5,2) state,
	   SUBSTR(ASR.ADDITIONAL_POINT_OF_TERM,5,2) POT,
	   SUBSTR(ASR.CONNECTING_FACILITY_ASSIGNMENT,24,2) CFASTATE,
	   trunc(t.scheduled_completion_date-4/24) APP_SCHED_DATE,
	   trunc(t.actual_completion_date-4/24) APP_ACTUAL_DATE,
	   trunc(t.revised_completion_date-4/24) APP_REVISED_DATE,
	   t2.task_type task_at_ready, 
	   t2.work_queue_id    
from asr_user_data aud, 
     access_service_request asr,
	 serv_req sr,
	 task t,
	 TASK T2,
	 task t3,
	 npa_nxx npa
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.document_number = t.document_number
  and sr.document_number = t2.document_number
  and sr.document_number = t3.document_number
  AND asr.NPA = NPA.NPA (+)
  and asr.nxx = npa.nxx (+)
  and to_char(asr.date_received,'yyyymmdd') = substr((TO_CHAR(SYSDATE-1,'YYYYMMDD')),1,8)   
  and asr.activity_indicator not in ('D','R')
  and asr.order_type = 'ASR'
  and asr.expedite_indicator = 'Y'
  and t.task_type = 'APP'
  and t2.task_status = 'Ready'
  and t3.actual_completion_date is null
)
  --
where (supp <> 1 or supp is null)
and (acna not in ('ZTK','ZZZ','ZWV') or acna is null)
)
order by 1