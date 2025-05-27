--old method   

select aud.document_number, 
       asr.request_type, 
	   max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) proj, 
       max(asr.date_received) keep (dense_rank first order by asr.last_modified_date) drec,
	   trunc(tapp.actual_completion_date) APP, 
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 
	   min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
	   trunc(t.actual_completion_date) DD_COMP,
	   trunc(tpcn.actual_completion_date) PCN_COMP, 
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 
	   max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,  
	   max(access_provider_serv_ctr_code) icsc2, 
	   max(sr.acna) acna,  
	   max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
	   max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop, 
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code, 
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) nl1clli,
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) nl2clli, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri, 
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) first_ckt,
	   det.date_received, icsc, asc_ec, eusa_sec_otc
from asr_user_data aud, 
     access_service_request asr,
	 serv_req sr,
	 network_location nl1,
	 network_location nl2,
	 design_layout_report dlr,
	 task_jeopardy_whymiss jw,
	 task t,
	 task tapp,
	 task tpcn,
	 circuit c,
	 data_ext.asr_detail det
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = dlr.document_number (+)
  and sr.document_number = t.document_number
  and sr.document_number = tapp.document_number (+)
  and sr.document_number = tpcn.document_number (+)
  and t.task_number = jw.task_number(+)
  and sr.document_number = det.document_number (+)
  and to_char(t.actual_completion_date,'yyyymm') in ('201208')    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
  and tapp.task_type = 'APP'
  and tpcn.task_type = 'CAD'
  and sr.acna in (
  'AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   			  'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWS','AWL','AWN','AZE','BAC',
				  'BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','CBL','CCB','CDA','CEL',
				  'CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
				  'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','ETP','EST','ETX',
				  'FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','HWC',
				  'IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
				  'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ',
				  'MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV',
				  'OSU','PCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN','SCU',
				  'SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM',
				  'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO',
				  'ATX','TPM','AAV','SBB','SBZ','SUV')
group by aud.document_number, asr.request_type, t.actual_completion_date, tapp.actual_completion_date, tpcn.actual_completion_date,
det.date_received, icsc, asc_ec, eusa_sec_otc



-- new method  


select aud.document_number, 
       asr.request_type, 
	   max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) proj, 
       max(asr.date_received) keep (dense_rank first order by asr.last_modified_date) drec,
	   trunc(tapp.actual_completion_date) APP, 
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 
	   min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
	   trunc(t.actual_completion_date) DD_COMP, 
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 
	   max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,  
	   max(access_provider_serv_ctr_code) icsc2, 
	   max(sr.acna) acna,  
	   max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
	   max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop, 
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code, 
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) nl1clli,
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) nl2clli, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri, 
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) first_ckt,
	   det.date_received, det.icsc, asc_ec, multi_ec_icsc1, multi_ec_icsc2
from asr_user_data aud, 
     access_service_request asr,
	 serv_req sr,
	 network_location nl1,
	 network_location nl2,
	 design_layout_report dlr,
	 task_jeopardy_whymiss jw,
	 task t,
	 task tapp,
	 circuit c,
	 data_ext.asr_detail det,
	 data_ext.asr_multi_ec ec
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = dlr.document_number (+)
  and sr.document_number = t.document_number
  and sr.document_number = tapp.document_number (+)
  and t.task_number = jw.task_number(+)
  and sr.document_number = det.document_number (+)
  and sr.document_number = ec.document_number (+)
  and to_char(t.actual_completion_date,'yyyymm') in ('201208')    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
  and tapp.task_type = 'APP'
  and sr.acna in (
  'AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   			  'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWS','AWL','AWN','AZE','BAC',
				  'BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','CBL','CCB','CDA','CEL',
				  'CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
				  'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','ETP','EST','ETX',
				  'FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','HWC',
				  'IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
				  'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ',
				  'MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV',
				  'OSU','PCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN','SCU',
				  'SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM',
				  'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO',
				  'ATX','TPM','AAV','SBB','SBZ','SUV')
group by aud.document_number, asr.request_type, t.actual_completion_date, tapp.actual_completion_date, 
det.date_received, det.icsc, asc_ec, multi_ec_icsc1, multi_ec_icsc2




