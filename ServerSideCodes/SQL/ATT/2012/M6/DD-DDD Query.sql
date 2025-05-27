drop table attpr;

create table attpr nologging nocache as
select document_number, req, drec, dd, ddd, comp_dt, nc, prod, pon, ckt, icsc, acna, comp, jeop, proj, 
       case when state = 'MD' then 'WV'
	        when state = 'KY' then 'IN' else state end state,
	   case WHEN STATE IN ('IL','MO','MN','ND','OH') THEN 'Central'
       		WHEN STATE IN ('IN','KY','MI') THEN 'Midwest'
	  		WHEN STATE IN ('NC','SC','WV','MD','VA') THEN 'Southeast'
	  		WHEN STATE IN ('CA','OR','WA') THEN 'West'
	  		WHEN STATE IN ('NY','PA') THEN 'Northeast'
	  		WHEN STATE IN ('AL','AZ','FL','GA','IA','ID','MS','MT','NE','NM','NV','TN','UT','WI') THEN 'National'
	  		ELSE 'Unknown' END REGION,		
       case when comp = 'MOB' and prod = 'DS1' then 'MOB DS1'
	        when comp = 'MOB' and prod = 'DS3' then 'MOB DS3'
			when comp = 'MOB' and prod like 'MOB Ethernet%' then prod
			when comp = 'MOB' and prod like 'OC%' then 'MOB'||' '||prod
	        when comp = 'ATX' and prod = 'DS1' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX DS1'
			when acna = 'TPM' and prod = 'DS1' and substr(pon,4,1) in ('P','Y') then 'ATX DS1'
			when comp = 'ATX' and prod = 'DS1' and substr(pon,3,1) in ('S','H') then 'ATX ALL DS1'
			when comp = 'ATX' and prod = 'DS3' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX DS3'
			when acna = 'TPM' and prod = 'DS3' and substr(pon,4,1) in ('P','Y') then 'ATX DS3'
			when comp = 'ATX' and prod = 'DS3' and substr(pon,3,1) in ('S','H') then 'ATX ALL DS3'
			when comp = 'ATX' and prod like 'OC%' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX'||' '||prod
			when comp = 'ATX' and prod like 'OC%' and substr(pon,3,1) in ('S','H') then 'ATX ALL'||' '||prod
			when comp = 'ATX' and prod ='DS0' and substr(pon,3,1) in ('S','H') then 'ATX ALL DS0'
			when comp = 'ATX' and substr(nc,1,1) = 'O' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'R' then 'ATX ACCU-Ring'
			when comp = 'ATX' and substr(nc,1,1) in ('H','O') and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'A' then 'ATX ACCU-Ring SCI'
			when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'E' then 'ATX Ethernet Prem to Switch'
			when comp = 'ATX' and prod = 'Ethernet' and substr(pon,4,1) = 'V' then 'ATX Ethernet VLAN'
			when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'S' then 'ATX Ethernet Check SEI'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'V' then 'MOB Ethernet EVC'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'K' and req = 'S' then 'MOB Ethernet MTSO'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'K' and req = 'E' then 'MOB Ethernet Cell'
			else 'EXCLUDE' end product,
	   case when comp_dt <= dd then 0
	        when comp_dt > dd and jeop in ('02','05','005','14','17','17H','18','18H','00A','00B','00C','1C','1E','1R') then 0
			else 1 end DD_MISS,
	   case when comp_dt <= ddd then 0
	        when comp_dt > ddd and jeop in ('02','05','005','14','17','17H','18','18H','00A','00B','00C','1C','1E','1R') then 0
			else 1 end DDD_MISS,
	   1 ord_count	   		
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
		pon, icsc, acna, 
		case when acna in ('ATX','AAV','SBB','SBZ','SUV','TPM') then 'ATX' else 'MOB' end comp, 
		proj, jeop, 
		case when nl2clli is not null then nl2clli 
             when nl1clli is not null then nl1clli
			 when pri is not null then pri
			 when sec is not null then sec
			 when substr(proj,1,10) in ('ATTMOB-TLS','ATTMOB-EVC') then substr(proj,12,2)
			 else null end state,
		clli_code, supp, ckt, req, nc
from (
select sr.document_number, 
       asr.request_type req, 
	   max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) proj, 
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) drec, 
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
	   max(aud.crdd) keep (dense_rank last order by aud.last_modified_date) DDD, 
	   max(aud.ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
	   trunc(t.actual_completion_date-5/24) DD_COMP, 
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 
	   max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,  
	   max(access_provider_serv_ctr_code) icsc, 
	   max(sr.acna) acna,  
	   max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
	   max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop,
	   jeopardy_type_cd jeop_type, 
	   max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code, 
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) nl1clli,
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) nl2clli, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri,    
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.network_location nl1,
	 casdw.network_location nl2,
	 casdw.design_layout_report dlr,
	 casdw.task_jeopardy_whymiss jw,
	 casdw.task t,
	 casdw.circuit c
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = dlr.document_number (+)
  and sr.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  and to_char(t.actual_completion_date,'yyyymm') = '201212'    --Current Reporting Month  
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
group by sr.document_number, asr.request_type, t.actual_completion_date
))
where icsc not in ('RT01','CU03','CZ02')
 and (supp <> 1 or supp is null) 
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders  
 and ddd is not null
order by 1



select * from attpr 

drop table attpr2;

create table attpr2 nologging nocache as
select document_number, pon, --last_modified_userid, last_modified_date,
       trunc(max(date_received) keep (dense_rank first order by asr.last_modified_date)) init,
	   trunc(max(date_received) keep (dense_rank last order by asr.last_modified_date)) clean
from casdw.access_service_request asr
where document_number in (select document_number from attpr)
and substr(last_modified_userid,1,3) in ('ASR','APP','ASA')
group by document_number, pon --,last_modified_userid, last_modified_date
order by document_number


select a.document_number, req, init, clean, null FOC, null "FOC Days", drec, dd, ddd, comp_dt, nc, prod, a.pon, ckt, icsc, acna, comp, 
       jeop, proj, state, region, product, DD_MISS, DDD_MISS, ord_count
from attpr a, attpr2 b
where a.document_number = b.document_number(+)
     
	 
	 
	 
--For Tammy - weekly misses  	 
select DOCUMENT_NUMBER,	REQ,DREC,DD,DDD,COMP_DT,NC,PROD,PON,CKT,ICSC,ACNA,COMP,JEOP,PROJ,STATE,REGION,PRODUCT,DD_MISS
from attpr
where dd_miss = 1
	   



