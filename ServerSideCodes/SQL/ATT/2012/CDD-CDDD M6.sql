

select document_number, req, drec, dd, ddd, comp_dt, nc, prod, pon, ckt, icsc, acna, comp, jeop, proj, 
       case when state = 'MD' then 'WV'
	        when state = 'KY' then 'IN' else state end state,
       case when comp = 'MOB' and prod = 'DS1' then 'MOB DS1'
	        when comp = 'MOB' and prod = 'DS3' then 'MOB DS3'
			when comp = 'MOB' and prod like 'MOB Ethernet%' then prod
			when comp = 'MOB' and prod like 'OC%' then 'MOB'||' '||prod
	        when comp = 'ATT' and prod = 'DS1' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX DS1'
			when acna = 'TPM' and prod = 'DS1' and substr(pon,4,1) in ('P','Y') then 'ATX DS1'
			when comp = 'ATT' and prod = 'DS1' and substr(pon,3,1) in ('S','H') then 'ATX ALL DS1'
			when comp = 'ATT' and prod = 'DS3' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX DS3'
			when acna = 'TPM' and prod = 'DS3' and substr(pon,4,1) in ('P','Y') then 'ATX DS3'
			when comp = 'ATT' and prod = 'DS3' and substr(pon,3,1) in ('S','H') then 'ATX ALL DS3'
			when comp = 'ATT' and prod like 'OC%' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX'||' '||prod
			when comp = 'ATT' and prod like 'OC%' and substr(pon,3,1) in ('S','H') then 'ATX ALL'||' '||prod
			when comp = 'ATT' and prod ='DS0' and substr(pon,3,1) in ('S','H') then 'ATX ALL DS0'
			when comp = 'ATT' and substr(nc,1,1) = 'O' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'R' then 'ATX ACCU-Ring'
			when comp = 'ATT' and substr(nc,1,1) in ('H','O') and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'A' then 'ATX ACCU-Ring SCI'
			when comp = 'ATT' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'E' then 'ATX Ethernet Prem to Switch'
			when comp = 'ATT' and prod = 'Ethernet' and substr(pon,4,1) = 'V' then 'ATX Ethernet VLAN'
			when comp = 'ATT' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'S' then 'ATX Ethernet Check SEI'
			else 'EXCLUDE' end product,
	   case when comp_dt <= dd then 0
	        when comp_dt > dd and jeop in ('2','5','14','17','18','55','64') then 0
			else 1 end DD_MISS,
	   case when comp_dt <= ddd then 0
	        when comp_dt > ddd and jeop in ('2','5','14','17','18','55','64') then 0
			else 1 end DDD_MISS,
	   1 ord_count						
from (
select document_number, req, trunc(drec) drec, trunc(dd) dd, ddd, 
       case when accept_dt is not null and accept_dt < dd_comp then accept_dt else dd_comp end comp_dt,
	   nc, 
       case when nc = 'HC' then 'DS1'
	        when nc = 'HF' then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
			when nc = 'OB' then 'OC3'
			when nc = 'OD' then 'OC12'
			when nc = 'OF' then 'OC48'
			when nc = 'OG' then 'OC192'
			when proj like 'ATTMOB-EVC%' then 'MOB Ethernet EVC'
			when proj like 'ATTMOB-TLS%' and req = 'S' then 'MOB Ethernet MTSO'
			when proj like 'ATTMOB-TLS%' and req = 'E' then 'MOB Ethernet Cell'
			when substr(nc,1,1) in ('K','V') then 'Ethernet'
			else ' ' end prod,   
	   pon, ckt, icsc, acna,
       case when acna in ('ATX','AAV','SBB','SBZ','SUV','TPM') then 'ATT' else 'MOB' end comp, 
	   jeop, proj,
	   case when state is not null then state 
            when pri is not null then pri
			when sec is not null then sec
			when substr(proj,12,2) = 'NY' then 'NY'
			when substr(proj,12,2) = 'WV' then 'WV'
			when substr(proj,12,2) = 'NC' then 'NC'
			when substr(proj,12,2) = 'IN' then 'IN'
			when substr(proj,12,2) = 'MI' then 'MI'
			end state
from (	
select aud.document_number, 
       asr.request_type req, 
	   max(asr.project_identification) proj,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
       min(asr.date_received) drec, 
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 
	   min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
	   trunc(t.actual_completion_date) DD_COMP, 
	   max(asr.network_channel_service_code) nc, 
	   max(asr.pon) pon,  
	   max(access_provider_serv_ctr_code) icsc, 
	   max(sr.acna) acna,  
	   max(asr.activity_indicator) act, 
	   max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop, 
	   jeopardy_type_cd jeop_type,
	   substr(max(clli_code),5,2) state, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri,
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.network_location nl,
	 casdw.design_layout_report dlr,
	 casdw.task_jeopardy_whymiss jw,
	 casdw.task t
where aud.document_number = asr.document_number
  and aud.document_number = sr.document_number(+)
  and asr.location_id = nl.location_id(+)
  and aud.document_number = dlr.document_number (+)
  and aud.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  and to_char(t.actual_completion_date,'YYYYMM') in ('201201')
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
  and sr.acna in ('ATX','AAV','SBB','SBZ','SUV','TPM','AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   		      'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN',
				  'BSM','CBL','CCB','CDA','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO',
			      'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL',
				  'HGN','HLU','HNC','HTN','IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA',
			      'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB',
				  'MWZ','NBC','NWW','OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN',
				  'SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD',
				  'VRA','WBT','WGL','WLG','WLZ','WVO','WWC')
group by aud.document_number, asr.request_type, jeopardy_type_cd, t.actual_completion_date
)where (supp <> 1 or supp is null)
 and ddd is not null
 )
order by 1