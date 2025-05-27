--ASR Orders   

   

select document_number, pon, ckt, acna, state, nc, act, proj, icsc, req, create_date, dd, acceptance_date, dd_comp, comp_dt, countable, whymiss,
       case when comp_dt > dd then 'Miss' else 'Met' end status
from (
select sr.document_number, 
       sr.pon, 
	   first_ecckt_id CKT,  
	   asr.desired_due_date dd,
	   asr.network_channel_service_code NC,
	   sr.acna,
	   sr.activity_ind ACT,
	   sr.project_identification PROJ,
	   access_provider_serv_ctr_code ICSC,
	   sr.request_type REQ,
	   trunc(date_time_sent) create_date,
	   trunc(asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222)) DD_COMP,
	   ACCEPTANCE_DATE,
	   case when asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) IS NULL AND ACCEPTANCE_DATE > DATE_TIME_SENT 
	             THEN ACCEPTANCE_DATE
	        WHEN ACCEPTANCE_DATE IS NULL AND asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) IS NOT NULL 
			     THEN asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222)
	        WHEN ACCEPTANCE_DATE <= asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) AND ACCEPTANCE_DATE > DATE_TIME_SENT 
			     THEN ACCEPTANCE_DATE
			WHEN asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) <= ACCEPTANCE_DATE 
			     THEN asap.pkg_gmt.sf_gmt_as_passed_timezone (t.actual_completion_date,1222) 
	        ELSE NULL END COMP_DT,
	   jeopardy_reason_code WHYMISS,
	   substr(nl.clli_code,5,2) state,
	   case when sr.project_identification is not null then 'Exclude PR-2'
	        when jeopardy_reason_code in ('02','05','005','14','17','17H','18','18H','00A','00B','00C','1C','1E','1R') then 'Exclude'
			else null end countable		
from serv_req sr,
     task t,
	 access_service_request asr,
	 asr_user_data aud,
	 circuit c,
	 network_location nl,
	 task_jeopardy_whymiss jw
where sr.document_number = t.document_number
and sr.document_number = asr.document_number (+)
and sr.document_number = aud.document_number
and sr.first_ecckt_id = c.exchange_carrier_circuit_id (+)
and c.location_id_2 = nl.location_id(+)
and t.task_number = jw.task_number(+)
and jw.jeopardy_type_cd(+) = 'W' 
and task_type = 'DD'
and type_of_sr = 'ASR'
and acna in ('AYD','DVN','ELG','OGT','ORO','PCL')
and to_char(t.actual_completion_date,'yyyymm') in ('201401')
and sr.activity_ind in ('N','M','C')
and substr(access_provider_serv_ctr_code,1,2) = 'FV'
and (sr.supplement_type <> '1' or sr.supplement_type is null)
and substr(first_ecckt_id,7,1) = 'U'
)



--SO Orders   
select sr.document_number, 
       sr.pon, 
	   first_ecckt_id ckt,
	   case when substr(first_ecckt_id,4,4) = 'TYNU' then 'ULD DS0'
	        when substr(first_ecckt_id,4,4) = 'DHSU' then 'ULD DS1'
			else 'Check' end product, 
	   trunc(t.revised_completion_date-4/24) DD,
	   sr.acna,
	   sr.activity_ind ACT,
	   sr.request_type REQ,
	   sr.project_identification PROJ,
	   trunc(t.actual_completion_date-4/24) DD_COMP,
	   ACCEPTANCE_DATE,
	   jeopardy_reason_code WHYMISS,
	   case when sr.project_identification is not null then 'Exclude PR-2'
	        when jeopardy_reason_code in ('02','05','005','14','17','17H','18','18H','00A','00B','00C','1C','1E','1R') then 'Exclude'
			else null end countable
from serv_req sr,
     task t,
	 asr_user_data aud,
	 task_jeopardy_whymiss jw
where sr.document_number = t.document_number
and sr.document_number = aud.document_number (+)
and t.task_number = jw.task_number(+)
and task_type = 'DD'
and acna in ('AYD','DVN','ELG','OGT','ORO','PCL')
and to_char(t.actual_completion_date,'yyyymm') in ('201312')
and sr.activity_ind in ('N','M','C')
and type_of_sr = 'SO'
and (sr.supplement_type <> '1' or sr.supplement_type is null)
and substr(first_ecckt_id,7,1) = 'U'


