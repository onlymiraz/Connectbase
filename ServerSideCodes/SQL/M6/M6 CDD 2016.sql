select distinct docno, pon, ckt, drec, dd, ddd, Comp_Dt, dd_task_comp, Prod, project, icsc, acna, expedite, why_miss, Why_Miss_Desc, state, district,
       case when district in ('NY','PA','CT') then 'East'
	        when district in ('IL','OH','WV') then 'Mid-Atlantic'
			when district in ('MI','WI') then 'Central'
			when district in ('CA','OR','WA','E WA / ID / MT') then 'West'
			when district in ('MN','NC','SC','AZ','NE') then 'National'
			when district in ('IN','TN') then 'Midwest'
			else 'Unknown' end region, npa, nxx,
	   CLLIZ, Orig_dd_status, orig_ddd_status
 from (      
select distinct document_number docno, pon, ckt, drec, dd, ddd, Comp_Dt, dd_comp dd_task_comp,  
       Prod, project, 
       icsc, acna, jeop why_miss, Why_Miss_Desc, state, 
	   case when npaarea is not null then npaarea
	        when cllizarea is not null then cllizarea
			when clliaarea is not null then clliaarea
	   		when state in ('NY','PA','CT','WA','OR','WI','ID','TN','IL','MN','OH','WV','NC','SC','IN','MI','NE') then state
			when state = 'CA' then 'AZ'
			when state in ('AZ','NV','NM','UT') then 'AZ'
			when state = 'MT' then 'ID'
			when state in ('AL','FL','GA','MS') then 'TN'
			when state = 'KY' then 'IN'
			when state = 'IA' then 'NE'
			when state = 'MO' then 'IL'
			when state in ('MD','VA') then 'WV'
			else state end district, clli_code, expedite,		
	   case when (comp_dt <= DD or DD is null) then 'Met'
	        when (comp_dt > DD and jeop in ('CU01','CU02','CU03','CU04','CU05','DS02','EX01')) then 'Met'
	        else 'Miss' end Orig_DD_Status,
	   case when (comp_dt <= DDD or DDD is null) then 'Met'
	        when (comp_dt > DDD and jeop in ('CU01','CU02','CU03','CU04','CU05','DS02')) then 'Met'
	        else 'Miss' end Orig_DDD_Status	,
		npa, nxx, clliz, cllia	
from (
select distinct document_number, trunc(drec) drec, dd, ddd, dd_comp, accept_dt, 
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
            when substr(nc,2,1) in ('SN') then 'Ethernet-NNI'
			when substr(ckt,4,1) in ('K') then 'Ethernet-UNI'
			when substr(ckt,4,1) in ('V') then 'Ethernet-EVC'
			when project like 'ATTMOB-%' then 'Ethernet'
			else ' ' end Prod,		
		pon, icsc, acna, project, jeop, jt.descript Why_Miss_Desc, clli_code, 
		case when npa.state is not null then npa.state
		     when clliz is not null then substr(clliz,5,2)
			 else substr(cllia,5,2) end state,
		supp, ckt, expedite, data.npa, data.nxx, wh.area_name npaarea, 
		cllia, wh1.area_name clliaarea, 
		clliz, wh3.area_name cllizarea
from (
select sr.document_number, 
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
	   max(substr(nl1.clli_code,1,6)) keep (dense_rank last order by nl1.last_modified_date) cllia,
	   max(substr(nl2.clli_code,1,6)) keep (dense_rank last order by nl2.last_modified_date) clliz, 
	   trunc(t.actual_completion_date-4/24) DD_COMP,
	   --max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
       max(sr.supplement_type) keep (dense_rank last order by sr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
	   max(expedite_indicator) keep (dense_rank last order by asr.last_modified_date) expedite,
	   max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
	   max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.network_location nl1,
	 casdw.network_location nl2,
	 casdw.task_jeopardy_whymiss jw,
	 casdw.task t,
	 casdw.circuit c
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  and to_char(t.actual_completion_date,'yyyymm') = '201603'    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
group by sr.document_number, asr.request_type, t.actual_completion_date
) data, 
  west_hierarchy wh,
  west_hierarchy wh1,
  west_hierarchy wh3,
  npanxx npa,
  jeopardy_type jt
  where data.NPA||data.NXX = wh.npanxx (+) 
  and cllia = wh1.clli6(+)
  and clliz = wh3.clli6 (+)
  and data.NPA||data.NXX = NPA.NPANXX (+)
  and jeop = jt.code(+)  
)
where icsc not in ('RT01')
 and (supp <> 1 or supp is null) 
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders  
 and (acna not in ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',
                   'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ','XYY') or acna is null)
)				   
order by 1


