drop table attncfr;
--PULL THIS FROM LAST MONTH'S COMPLETED ORDER REPORT    
--create table attncfr nologging nocache as
select document_number, req, drec, dd, ddd, comp_dt, nc, prod, pon, ckt, icsc, acna, comp, jeop, proj, state, 
       case WHEN STATE IN ('AZ','NV','NM','UT','WI','AL','FL','GA','MS','TN','NC','SC') THEN 'National'
			WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
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
			when comp = 'ATX' and substr(nc,1,1) = 'O' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'R' then 'ATX ACCU-Ring'
			when comp = 'ATX' and substr(nc,1,1) in ('H','O') and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'A' then 'ATX ACCU-Ring SCI'
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
	        when comp_dt > dd and jeop in ('CU01','CU02','CU03','CU04','CU05') then 0
			else 1 end DD_MISS,
	   case when comp_dt <= ddd then 0
	        when comp_dt > ddd and jeop in ('CU01','CU02','CU03','CU04','CU05') then 0
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
  and to_char(t.actual_completion_date,'yyyymm') = '201503'    --Previous Reporting Month  
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
order by 1;




select * from attncfr
where region = 'Unknown';




select product, sum(num) NUM, sum(den) DEN
from (
select product, count(*) num, NULL den
from (

select * from (
select distinct CKT, PRODUCT,
   max(trbl_found_id) keep (dense_rank last order by rep.last_modified_date) trbl_found_id, 
   max(tt_type_cd) keep (dense_rank last order by rep.last_modified_date) tt_type_cd
   from ATTNCFR PRV, casdw.TROUBLE_TICKET REP
   where PRV.CKT = REP.SERV_ITEM_DESC (+)    
   and TO_CHAR(REP.CREATE_DATE,'YYYYMMDD') >= TO_CHAR(PRV.COMP_DT,'YYYYMMDD') 
   and REP.CREATE_DATE - PRV.COMP_DT <=30  
   AND REP.CURRENT_STATE = 'closed'
   AND RESP_ORG_PARTY_ID IN ('518336','540992','541368')	
   group by ckt, product					 			 
 )					 
 where tt_type_cd <> 'INFORMATION'
 and TRBL_FOUND_ID in ('242','243','276','289','290','291','245','246','247','254','255','256',
                       '257','258','259','260','284','285','286','287','288','297','300')
 --group by product


--
 UNION ALL
--
select product, null NUM, count(*) den
from ATTNCFR
 group by product
 ) 
 group by  product
 order by product
 
 
 
 
--by Region   
select product, region, sum(num) NUM, sum(den) DEN
from (
select product, region, count(*) num, NULL den
from (
select distinct CKT, PRODUCT, region,
   max(trbl_found_id) keep (dense_rank last order by rep.last_modified_date) trbl_found_id, 
   max(tt_type_cd) keep (dense_rank last order by rep.last_modified_date) tt_type_cd
   from ATTNCFR PRV, casdw.TROUBLE_TICKET REP
   where PRV.CKT = REP.SERV_ITEM_DESC (+)    
   and TO_CHAR(REP.CREATE_DATE,'YYYYMMDD') >= TO_CHAR(PRV.COMP_DT,'YYYYMMDD') 
   and REP.CREATE_DATE - PRV.COMP_DT <=30  
   AND REP.CURRENT_STATE = 'closed'
   AND RESP_ORG_PARTY_ID IN ('518336','540992','541368')
   group by ckt, product, region
  ) 	
 where product in ('ATX DS1','ATX DS3','MOB DS1','MOB DS3')		
   and TT_TYPE_CD <> 'INFORMATION'
   and TRBL_FOUND_ID in ('242','243','276','289','290','291','245','246','247','254','255','256',
                         '257','258','259','260','284','285','286','287','288','297','300')		 
 group by product, region
--
 UNION ALL
--
select product, region, null NUM, count(*) den
from ATTNCFR
where product in ('ATX DS1','ATX DS3','MOB DS1','MOB DS3')
 group by product, region
 ) 
 group by  product, region
 order by product, region
 
 
 
 select * from attncfr 
 
 
 
 --Detail  Not done yet    
 select ckt, document_number, state, pon, product, comp_dt, create_date trbl_create_date, a.trbl_found_id, TFT.TROUBLE_FOUND_CD, tt_type_cd, ticket_id, cleared_comment
 from (
 select distinct CKT, prv.document_number, prv.state, prv.pon, product, comp_dt, create_date, 
   max(trbl_found_id) keep (dense_rank last order by rep.last_modified_date) trbl_found_id, 
   max(tt_type_cd) keep (dense_rank last order by rep.last_modified_date) tt_type_cd, TICKET_ID,
   replace(replace(REP.CLEARED_COMMENT,chr(10),''),chr(13),'') cleared_comment
   from ATTNCFR PRV, casdw.TROUBLE_TICKET REP
   where PRV.CKT = REP.SERV_ITEM_DESC (+)    
   and TO_CHAR(REP.CREATE_DATE,'YYYYMMDD') >= TO_CHAR(PRV.COMP_DT,'YYYYMMDD') 
   and REP.CREATE_DATE - PRV.COMP_DT <=30  
   AND REP.CURRENT_STATE = 'closed'
   AND RESP_ORG_PARTY_ID IN ('518336','540992','541368')	
   group by ckt, prv.document_number, product, comp_dt, create_date, state, prv.pon, cleared_comment, ticket_id				 			  
 )	a, casdw.TROUBLE_FOUND_TYPE tft
  where a.TRBL_FOUND_ID = TFT.TRBL_FOUND_ID (+)				 
 and tt_type_cd <> 'INFORMATION'
 and a.TRBL_FOUND_ID in ('242','243','276','289','290','291','245','246','247','254','255','256',
                       '257','258','259','260','284','285','286','287','288','297','300')
 order by 5,1,7;	
 
 
 
 
--to pull troubles from Remedy    

select ckt_id, product, create_date, cleared_dt, closed_dt, ttr, repair_code, disp, ticket_id
from (
select distinct ckt_id, product, create_date, cleared_dt, closed_dt, ttr, repair_code,		
	   case when disp3 is not null then disp3
	        when disp is not null then disp
	        else disp2 end disp, 
       ticket_id
from (
select distinct ticket_id, 
       case when acna is not null then acna
	        when acna1 is not null then acna1
	        when ccna1 is not null then ccna1
			when acna2 is not null then acna2
            else ccna2 end CLEC_ID, 		
       ckt_id,  
	   case when service_type_code = 'HC' then 'DS1'
			when service_type_code = 'HF' then 'DS3'
	   	 	when substr(circuit,4,5) like '%T1%' then 'DS1'
			when substr(circuit,4,5) like '%T3%' then 'DS3'
			when substr(circuit,1,4) like '%HC%' then 'DS1'
			when substr(circuit,1,4) like '%HF%' then 'DS3'
			when substr(circuit,1,2) = 'R2' then 'Ethernet'
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'
			when substr(circuit,3,1) in ('X','L') then 'DS0'
			when substr(service_type_code,1,2) = 'OC' then 'OCN'
			when substr(circuit,1,8) like '%OC%' then 'OCN'
			when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
			else ' ' end product,
	   case when to_char(Create_Date,'yyyymmdd') > '20151101' then Create_Date-5/24 
	        else Create_Date-4/24 end create_date, 
	   case when to_char(Cleared_Dt,'yyyymmdd') > '20151101' then Cleared_dt-5/24
	        else Cleared_dt-4/24 end Cleared_Dt, 
	   case when to_char(Closed_Dt,'yyyymmdd') > '20151101' then Closed_dt-5/24
	        else Closed_dt-4/24 end Closed_Dt,
       Total_Duration, 
	   TTR,
	   b.trbl_found_number, b.trbl_found_desc, b.disp, c.trbl_found_number trbl_found_number2, c.trbl_found_desc trbl_found_desc2, c.disp disp2, d.disp disp3,
	   site_id, a.repair_code, serv_code
from (
select a.fld_requestid ticket_id, 
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
	   a.exchange_carrier_circuit_id ckt_id, 
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
	   max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,
	   max(d.acna) keep (dense_rank first order by d.acna) acna2, 
	   max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
	   max(round(a.h_fld_totalopentime_secs_/3600,2)) keep (dense_rank last order by a.fld_modifieddate) Total_Duration,
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
	   max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,  
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
	   MAX(E.SERVICE_TYPE_CODE) KEEP (DENSE_RANK LAST ORDER BY E.LAST_MODIFIED_DATE) SERV_CODE,
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile = 'CNOC'
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (e.type <> 'T' or type is null) 
and (to_char(dte_closeddatetime-5/24,'yyyymm') in ('201511','201512') or dte_closeddatetime is null)   --NEED TO CHANGE THIS EACH MONTH
 and to_char(a.fld_startdate,'yyyymm') > '201508' --DO NOT CHANGE UNTIL CLOSED DATE IS FIXED 
 --AND d.ISSUE_STATUS = '2'
 and e.status (+) = '6'
group by a.fld_requestid, a.exchange_carrier_circuit_id 
) a, trbl_found_remedy b, repair_code c, trbl_found_remedy d
where a.trbl_found_cd = b.trbl_found_number (+)
and a.repair_code = c.repair_code (+)
and a.repair_code = d.trbl_found_desc (+)
and substr(circuit,6,1) <> 'U'   
and request_type in ('Agent','Alarm','Customer','Maintenance')
and substr(ckt_id,4,2) not in ('VM','EM','IP','IB','FX','YB','YG','UG','UH','RT','PL','LA','LU','XA','LA','LO','LN','LU','FD','US','CS')
and reqstat = 'Closed'
and (to_char(cleared_dt,'yyyymm') in ('201511','201512') 
   or to_char(closed_dt,'yyyymm') in ('201511','201512'))          --NEED TO CHANGE THIS EACH MONTH  
)
where clec_id in ('ATX','AAV','SBB','SBZ','SUV','TPM','AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   		    'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN',
				'BSM','CBL','CCB','CDA','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO',
			    'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL',
				'HGN','HLU','HNC','HTN','IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA',
			    'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB',
				'MWZ','NBC','NWW','OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN',
				'SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD',
				'VRA','WBT','WGL','WLG','WLZ','WVO','WWC')	
)				
where disp in ('CO','FAC')				
order by 1,3;							  	 
