select distinct document_number docno, pon, ckt, drec, dd, ddd, Comp_Dt, dd_comp dd_task_comp,  					
       Prod, project, 					
       acna, jeop, state, 					
	   case when state in ('NY','PA','OH','WV','MD','VA') then 'East'
			when state in ('IL','MN','IN','MI','KY','IA','NE') then 'Central'
			when state in ('CA','OR','WA','ID','MT') then 'West'
			when state in ('AZ','NV','NM','UT','WI','AL','FL','GA','MS','TN','NC','SC') then 'National'		
			else null end region, 		
	   case when (comp_dt <= DD or DD is null) then 'Met'				
	        when (comp_dt > DD and jeop in ('02','05','005','14','17','17H','18','18H','00A','00B','00C','1C','1E','1R')) then 'Met'				
	        else 'Miss' end Orig_DD_Status,				
	   build				
from (					
select document_number, trunc(drec) drec, dd, ddd, dd_comp, accept_dt, 					
       case when dd_comp is null and accept_dt > drec then Accept_dt					
	        when Accept_dt is null then dd_comp				
	        when Accept_dt <= dd_comp and accept_dt > drec then Accept_dt 				
	        else dd_comp end Comp_Dt, 				
	   case when nc = 'HC' then 'DS1'				
	        when nc = 'HF' then 'DS3'				
			when substr(nc,1,1) in ('L','X') then 'DS0'		
			when nc in ('OB','OD','OF','OG') then 'OCN'		
			when substr(nc,1,1) in ('K') then 'Ethernet-UNI'		
			when substr(nc,1,1) in ('V') then 'Ethernet-EVC'		
			when substr(ckt,4,1) in ('K') then 'Ethernet-UNI'		
			when substr(ckt,4,1) in ('V') then 'Ethernet-EVC'		
			when project like 'ATTMOB-%' then 'Ethernet'		
			else ' ' end Prod,		
		pon, icsc, acna, project, jeop, 			
		case when nl2clli in ('NY','PA','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA') then nl2clli 			
             when nl1clli in ('NY','PA','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA') then nl1clli					
			 when pri in ('NY','PA','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA') then pri		
			 when sec in ('NY','PA','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE','CA','AZ','NV','NM','UT','MT','AL','FL','GA','MS','KY','IA','MO','MD','VA') then sec		
			 when substr(project,1,10) in ('ATTMOB-TLS','ATTMOB-EVC') then substr(project,12,2)		
			 else null end state,		
		clli_code, supp, ckt, expedite, 
		case when coe = 'Y' then 'Build'
		     when con = 'Y' then 'Build'
			 else 'No Build' end Build			
from (					
select aud.document_number, 					
       asr.request_type, 					
	   max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) project, 				
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) drec, 					
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 				
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 				
	   min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt, 				
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 				
	   max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,  				
	   max(access_provider_serv_ctr_code) icsc, 				
	   max(sr.acna) acna,  				
	   max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 				
	   max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop, 				
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code, 				
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) nl1clli,				
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl2.last_modified_date) nl2clli,				
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) nl1st,				
	   max(nl2.clli_code) keep (dense_rank last order by nl2.last_modified_date) nl2st,				
	   max(secloc_state) sec, 				
	   max(priloc_state) pri, 				
	   trunc(t.actual_completion_date-4/24) DD_COMP,				
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,				
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,				
	   max(expedite_indicator) keep (dense_rank last order by asr.last_modified_date) expedite,				
	   max(t2.required_ind) keep (dense_rank last order by T2.last_modified_date) COE,				
       max(t3.required_ind) keep (dense_rank last order by T3.last_modified_date) CON					
from casdw.asr_user_data aud, 					
     casdw.access_service_request asr,					
	 casdw.serv_req sr,				
	 casdw.network_location nl1,				
	 casdw.network_location nl2,				
	 casdw.design_layout_report dlr,				
	 casdw.task_jeopardy_whymiss jw,				
	 casdw.task t,				
	 casdw.TASK T2,				
	 casdw.TASK T3,				
	 casdw.circuit c				
where sr.document_number = asr.document_number					
  and sr.document_number = aud.document_number(+)					
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id					
  and c.location_id = nl1.location_id(+)					
  and c.location_id_2 = nl2.location_id(+)					
  and sr.document_number = dlr.document_number (+)					
  and sr.document_number = t.document_number					
  and sr.document_number = t2.document_number(+)					
  and sr.document_number = t3.document_number(+)					
  and t.task_number = jw.task_number(+)					
  and to_char(t.actual_completion_date,'yyyymm') = '201309'    --Current Reporting Month  					
  and asr.request_type in ('S','E')					
  and asr.activity_indicator in ('N','C')					
  and asr.order_type = 'ASR'					
  and jw.jeopardy_type_cd(+) = 'W' 					
  and t.task_type = 'DD'					
  AND T2.TASK_TYPE(+) = 'COE_COMP'					
  AND T3.TASK_TYPE(+) = 'CON_COMP'					
group by aud.document_number, asr.request_type, t.actual_completion_date					
))					
where icsc not in ('RT01','CU03','CZ02')					
 and (supp <> 1 or supp is null) 					
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders  					
 and state is not null					
 and (acna not in ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',					
                   'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ') or acna is null)					
order by 1					
