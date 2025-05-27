select sr.DOCUMENT_NUMBER, sr.PON, sr.PROJECT_IDENTIFICATION, FIRST_ECCKT_ID, sr.ACNA, trunc(DATE_RECEIVED) date_received, asr.DESIRED_DUE_DATE, sr.REQUEST_TYPE, sr.REQUEST_TYPE_STATUS, ACTIVITY_IND,
sr.SUPPLEMENT_TYPE, ACCESS_PROVIDER_SERV_CTR_CODE ICSC, prov.plan_name                                       
from serv_req sr, 
     access_service_request asr, 
     task t,  
     svcreq_provplan pp, 
     provisioning_plan prov                                        
where sr.document_number = asr.document_number                                       
and sr.document_number = t.document_number (+) 
and t.req_plan_id = pp.req_plan_id (+)                                        
and pp.plan_id = prov.plan_id (+) 
and t.task_type = 'DD'
and prov.plan_id = '13405'                                                                                
and (asr.supplement_type <> 1 or asr.supplement_type is null)
and t.actual_completion_date is null;

