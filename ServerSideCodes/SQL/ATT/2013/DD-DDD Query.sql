drop table attpr;

create table attpr nologging nocache as
select document_number, req, drec, dd, ddd, comp_dt, nc, prod, pon, ckt, icsc, acna, comp, jeop, b.jeopardy_reason_description miss_reason, proj, state, asr_init init,
	   case WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
	        WHEN STATE IN ('IN','KY','AL','FL','GA','MS','TN') THEN 'MIDWEST'
       		WHEN STATE IN ('NY','PA','CT') THEN 'EAST'
			WHEN STATE IN ('IL','MO','OH','WV','MD','VA') THEN 'MID-ATLANTIC'
	  		WHEN STATE IN ('CA','OR','WA','ID','MT') THEN 'WEST'
	  		WHEN STATE IN ('AZ','NM','NV','UT','MN','SC','NC','IA','NE') THEN 'NATIONAL'
	  		ELSE 'Unknown' END REGION,		
       case when comp = 'MOB' and prod = 'DS1' then 'MOB DS1'
	        when comp = 'MOB' and prod = 'DS3' then 'MOB DS3'
			when comp = 'MOB' and prod like 'MOB Ethernet%' then prod
			when comp = 'MOB' and prod like 'OC%' then 'MOB'||' '||prod
	        when comp = 'ATX' and prod = 'DS1' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX DS1'
			when acna = 'TPM' and prod = 'DS1' and substr(pon,4,1) in ('P','Y') then 'ATX DS1'
			when acna in ('SBB','SBZ','AAV','SUV') and prod = 'DS1' then 'ATX DS1'
			when comp = 'ATX' and prod = 'DS1' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'X' then 'ATX ESO DS1'
			when comp = 'ATX' and prod = 'DS3' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX DS3'
			when acna = 'TPM' and prod = 'DS3' and substr(pon,4,1) in ('P','Y') then 'ATX DS3'
			when acna in ('SBB','SBZ','AAV','SUV') and prod = 'DS3' then 'ATX DS3'
			when comp = 'ATX' and prod = 'DS3' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'X' then 'ATX ESO DS3'
			when comp = 'ATX' and prod like 'OC%' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX'||' '||prod
			when comp = 'ATX' and prod like 'OC%' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'X' then 'ATX ESO'||' '||prod
			when comp = 'ATX' and prod ='DS0' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'X' then 'ATX ESO DS0'
			when comp = 'ATX' and substr(nc,1,1) = 'O' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'R' then 'ATX A-Ring'
			when comp = 'ATX' and substr(nc,1,1) in ('H','O') and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'A' then 'ATX A-Ring SCI'
			when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'E' then 'ATX Ethernet Prem to Switch'
			when comp = 'ATX' and prod = 'Ethernet' and substr(pon,4,1) = 'V' then 'ATX Ethernet VLAN'
			when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'S' then 'ATX Ethernet Pop to Check SEI'
			when comp = 'ATX' and prod = 'Ethernet' and substr(pon,4,1) = 'C' then 'ATX Ethernet Combo'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'V' then 'MOB Ethernet EVC'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'K' and req = 'S' then 'MOB Ethernet MTSO'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'K' and req = 'E' then 'MOB Ethernet Cell'
			when acna = 'ATX' and substr(pon,3,1) = 'H' then 'ATX IOF'  
			else 'EXCLUDE' end product,
	   case when comp_dt <= dd then 0
	        when comp_dt > dd and jeop in ('CU01','CU02','CU03','CU04','CU05','DS02','EX01') then 0
			else 1 end DD_MISS,
	   case when comp_dt <= ddd then 0
	        when comp_dt > ddd and jeop in ('CU01','CU02','CU03','CU04','CU05','DS02') then 0
			else 1 end DDD_MISS,
	   1 ord_count, conf_dt, build   		
from (
select document_number, trunc(drec) drec, dd, ddd, dd_comp, accept_dt, 
       case when dd_comp is null and accept_dt > drec then Accept_dt
	        when Accept_dt is null then dd_comp
	        when Accept_dt <= dd_comp and accept_dt > drec then Accept_dt 
	        else dd_comp end Comp_Dt, 
	   case when nc = 'HC' then 'DS1'
	        when nc = 'HF' then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
			when nc = 'OB' then 'OC3'
			when nc = 'OD' then 'OC12'
			when nc = 'OF' then 'OC48'
			when nc = 'OG' then 'OC192'
			when substr(nc,1,1) in ('K','V') then 'Ethernet'
			when substr(ckt,3,2) in ('/K','/V') then 'Ethernet'
			when proj like 'ATTMOB-%' then 'Ethernet'
			else ' ' end Prod,		
		pon, icsc, acna, asr_init, 
		case when acna in ('ATX','AAV','SBB','SBZ','SUV','TPM') then 'ATX' else 'MOB' end comp, 
		proj, jeop, 
		case when nl2clli is not null then nl2clli 
             when nl1clli is not null then nl1clli
			 when pri is not null then pri
			 when sec is not null then sec
             when icsc = 'SN01' then 'CT'
			 when substr(proj,1,10) in ('ATTMOB-TLS','ATTMOB-EVC') then substr(proj,12,2)
			 else null end state,
		clli_code, supp, ckt, req, nc, conf_dt, jeop_type, 
		CASE WHEN BUILD = '207' THEN 'YES'
		     when coe = 'Y' then 'YES'
		     when con = 'Y' then 'YES'
		     ELSE 'NO' END BUILD
from (
select sr.document_number, 
       asr.request_type req, 
	   max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) proj, 
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) drec, 
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 
	   max(aud.ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
	   trunc(t.actual_completion_date)  DD_COMP,
	   max(trunc(t2.actual_completion_date)) keep (dense_rank last order by t.last_modified_date) CONF_DT, 
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 
	   max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,  
	   max(access_provider_serv_ctr_code) icsc, 
	   max(sr.acna) acna,  
	   max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
	   max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop,
	   jeopardy_type_cd jeop_type, 
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code, 
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) nl1clli,
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl2.last_modified_date) nl2clli, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri,    
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
	   MAX(AUD.CONSTRUCTION_REQUIRED) KEEP (DENSE_RANK LAST ORDER BY AUD.LAST_MODIFIED_DATE) BUILD,
	   max(t3.required_ind) keep (dense_rank last order by T2.last_modified_date) COE,				
       max(t4.required_ind) keep (dense_rank last order by T3.last_modified_date) CON,
	   build_iof, build_osp,
       min(nts.last_modified_date) keep (dense_rank first order by nts.last_modified_date) asr_init
from asr_user_data aud, 
     access_service_request asr,
	 serv_req sr,
	 network_location nl1,
	 network_location nl2,
	 design_layout_report dlr,
	 task_jeopardy_whymiss jw,
	 task t,
	 task t2,
	 task t3,
	 task t4,
	 circuit c,
     NOTES NTS
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = dlr.document_number (+)
  and sr.document_number = t.document_number
  and sr.document_number = t2.document_number (+)
  and sr.document_number = t3.document_number (+)
  and sr.document_number = t4.document_number (+)
  and t.task_number = jw.task_number(+)
  AND SR.DOCUMENT_NUMBER = NTS.DOCUMENT_NUMBER (+)
  and to_char(t.actual_completion_date,'yyyymm') = '201512'    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD' 
  --and sr.document_number = '1200170'
  and t2.task_type(+) = 'ASR-CONF'
  AND T3.TASK_TYPE(+) = 'COE_COMP'					
  AND T4.TASK_TYPE(+) = 'CON_COMP'	
  and sr.acna in ('ATX','AAV','SBB','SBZ','SUV','TPM','AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   		      'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN',
				  'BSM','CBL','CCB','CDA','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO',
			      'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL',
				  'HGN','HLU','HNC','HTN','IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA',
			      'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB',
				  'MWZ','NBC','NWW','OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN',
				  'SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD',
				  'VRA','WBT','WGL','WLG','WLZ','WVO','WWC')
group by sr.document_number, asr.request_type, t.actual_completion_date, jeopardy_type_cd, build_iof, build_osp
)) a, jeopardy_type b
where a.jeop = b.jeopardy_reason_code(+) 
  and a.jeop_type = b.jeopardy_type_cd(+)
 and icsc not in ('RT01','CU03','CZ02')
 and (supp <> 1 or supp is null) 
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders  
 and ddd is not null
order by 1;



--NOT USING ATTPR2 anymore  
drop table attpr2;

create table attpr2 nologging nocache as
select document_number, pon, --last_modified_userid, last_modified_date,
       trunc(max(date_received) keep (dense_rank first order by asr.last_modified_date)) init,
	   trunc(max(date_received) keep (dense_rank last order by asr.last_modified_date)) clean
from access_service_request asr
where document_number in (select document_number from attpr)
and substr(last_modified_userid,1,3) in ('ASR','APP','ASA')
group by document_number, pon --,last_modified_userid, last_modified_date
order by document_number;



select a.document_number, req, trunc(init) init, null clean, conf_dt, null FOC, null "FOC Days", build, drec, dd, ddd, comp_dt, nc, prod, a.pon, ckt, icsc, acna, comp, 
       jeop, miss_reason, proj, state, region, product, DD_MISS, DDD_MISS, ord_count
from attpr a --, attpr2 b
where product not like '%ESO%';
     
	 
	 
	 

	   


