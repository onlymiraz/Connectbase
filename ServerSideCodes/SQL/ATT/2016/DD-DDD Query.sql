drop table attpr
/

create table attpr nologging nocache as
select document_number docno, req, act, init, case when clean < init then init else clean end clean, clean ctf_init,
       dd, comp_dt, nc, prod, pon, ckt, icsc, acna, comp, dd_comp, jeop, 
       b.jeopardy_reason_description miss_reason, proj, state, 
	   case WHEN STATE IN ('NY','PA','CT') THEN 'OA1'
	        WHEN STATE IN ('MI','OH','WV') THEN 'OA2'
            WHEN STATE IN ('AL','FL','GA','MS','NC','SC','TN') THEN 'OA3'
       		WHEN STATE IN ('IA','IL','IN','MN','NE','WI','KY','MO') THEN 'OA4'
			WHEN STATE IN ('AZ','NV','NM','TX','UT') THEN 'OA5'
            WHEN STATE IN ('ID','MT','OR','WA') THEN 'OA6'
	  		WHEN STATE IN ('CA') THEN 'OA7'
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
			when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'E' then 'ATX Ethernet UNI'
			when comp = 'ATX' and prod = 'Ethernet' and substr(pon,4,1) = 'V' then 'ATX Ethernet VLAN'
			when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'S' and sei = 'Y' then 'ATX Ethernet Pop to Switch'
            when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'S' and sei is null then 'ATX Ethernet Pop to Prem'
			when comp = 'ATX' and prod = 'Ethernet' and substr(pon,4,1) = 'C' then 'ATX Ethernet Combo'
            when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'V' then 'MOB Ethernet EVC'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'K' and req = 'S' then 'MOB Ethernet MTSO'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'K' and req = 'E' then 'MOB Ethernet UNI'
			when acna = 'ATX' and substr(pon,3,1) = 'H' then 'ATX IOF'  
			else 'EXCLUDE' end product,
	   case when comp_dt <= dd then 1
	        when comp_dt > dd and jeop in ('CU01','CU02','CU03','CU04','CU05','DS02','CA22','EX01','CU51','CU52','CU53','DS52') then 1
			else 0 end DD_MET, 
       build, build_iof, build_osp, bdw, OSP_BDT_REQD, OSPREVW_BDT_REQD, COEREVW_BDT_REQD, COEREVWA_BDT_REQD, COEREVWZ_BDT_REQD 		
from (
select document_number, trunc(clean) clean, dd, dd_comp, accept_dt, 
       case when dd_comp is null and accept_dt > clean then Accept_dt
	        when Accept_dt is null then dd_comp
	        when Accept_dt <= dd_comp and accept_dt > clean then Accept_dt 
	        else dd_comp end Comp_Dt, 
	   case when nc = 'HC' then 'DS1'
	        when nc = 'HF' then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
            when nc in ('OB','OD','OF','OG') then 'OCN'
			when substr(nc,1,1) in ('K','V') then 'Ethernet'
			when substr(ckt,3,2) in ('/K','/V') then 'Ethernet'
			when proj like 'ATTMOB-%' then 'Ethernet'
			else ' ' end Prod,	
       case when svc_cd in ('KD','KP') then '10M'
            when svc_cd in ('KE','KQ') then '100M'    			
            when svc_cd in ('KF','KR') then '1G'
            when svc_cd in ('KG','KS') then '10G'
            when svc_cd = 'VL' then 'EVC'
            else null end BDW,   	
		pon, icsc, acna, trunc(asr_init) init, 
		case when acna in ('ATX','AAV','SBB','SBZ','SUV','TPM') then 'ATX' else 'MOB' end comp, 
		proj, jeop, state, sei, act, 
		supp, ckt, req, nc, jeop_type, npa, 
		CASE when build_iof in ('344','345','346','347','348','349','350','351','352','353','354','355','356') then 'YES'
			 when build_osp in ('358','359','360','361','362','363','364') then 'YES'
		     ELSE 'NO' END BUILD,
       case when build_iof = '343' then '01-IOF - No Construction Required'
            when build_iof = '344' then '02-IOFMINOR - Place RT Card'
            when build_iof = '345' then '03-IOFMINOR - Place Fiber Riser/Dark Fiber Jumper'
            when build_iof = '346' then '04-IOFMINOR - Non EWO/Records Update'
            when build_iof = '347' then '05-IOFMINOR - Non EWO/Test and Tag (Specials)'
            when build_iof = '348' then '06-IOFMINOR - Non EWO/Carrier CLO'
            when build_iof = '349' then '07-IOFMAJOR - New RT Shelf'
            when build_iof = '350' then '08-IOFMAJOR - New RT MUX w/Existing Fiber'
            when build_iof = '351' then '09-IOFMAJOR - New RT MUX and Fiber <2,500'
            when build_iof = '352' then '10-IOFMAJOR - New RT MUX and Fiber >2,500'
            when build_iof = '353' then '11-IOFMAJOR - New RT MUX w/ROW and Structure'
            when build_iof = '354' then '12-IOFMAJOR - New RT Shelf and Fiber'
            when build_iof = '355' then '13-IOFMAJOR - Place Fiber Riser/Dark Fiber Jumper'
            when build_iof = '356' then '14-IOFMAJOR - Place FDP'
            else null end build_IOF,
       case when build_osp = '357' then '01-OSP - No Construction Required'
            when build_osp = '358' then '02-OSPMINOR - Loop Conditioning'
            when build_osp = '359' then '03-OSPMINOR - Doubler Installation'
            when build_osp = '360' then '04-OSPMAJOR - Constr-Copper Placing'
            when build_osp = '361' then '05-OSPMAJOR  -Fiber Placing/Fiber Splicing Work-Minor'
            when build_osp = '362' then '06-OSPMAJOR - Fiber Placing/Fiber Splicing <2,500'
            when build_osp = '363' then '07-OSPMAJOR - Fiber Placing/Fiber Splicing >2,500'
            when build_osp = '364' then '08-OSPMAJOR - Place FDP'
            else null end build_OSP,
       case when osp_bdt_reqd = '390' then 'Y' when osp_bdt_reqd = '391' then 'N' when osp_bdt_reqd = '392' then 'A' else null end osp_bdt_reqd,
       case when osprevw_bdt_reqd = '390' then 'Y' when osprevw_bdt_reqd = '391' then 'N' when osprevw_bdt_reqd = '392' then 'A' else null end osprevw_bdt_reqd,     
       case when coerevw_bdt_reqd = '390' then 'Y' when coerevw_bdt_reqd = '391' then 'N' when coerevw_bdt_reqd = '392' then 'A' else null end coerevw_bdt_reqd,     
       case when coerevwa_bdt_reqd = '390' then 'Y' when coerevwa_bdt_reqd = '391' then 'N' when coerevwa_bdt_reqd = '392' then 'A' else null end coerevwa_bdt_reqd,
       case when coerevwz_bdt_reqd = '390' then 'Y' when coerevwz_bdt_reqd = '391' then 'N' when coerevwz_bdt_reqd = '392' then 'A' else null end coerevwz_bdt_reqd
from (
select sr.document_number, 
       asr.request_type req, 
	   max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) proj, 
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) clean, 
	   max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD,
	   max(aud.ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
	   trunc(t.actual_completion_date)  DD_COMP,
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 
	   max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,  
	   max(access_provider_serv_ctr_code) icsc, 
	   max(sr.acna) acna,  
	   max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
	   max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop,
	   jeopardy_type_cd jeop_type,    
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
	   build_iof, build_osp, OSP_BDT_REQD, OSPREVW_BDT_REQD, COEREVW_BDT_REQD, COEREVWA_BDT_REQD, COEREVWZ_BDT_REQD,
       min(nts.last_modified_date) keep (dense_rank first order by nts.last_modified_date) asr_init,
       eusa_sec_sei sei,
       max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
       max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
	   max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx,
       substr(npa.exchange_area_clli,5,2) state
from asr_user_data aud, 
     access_service_request asr,
	 serv_req sr,
	 task_jeopardy_whymiss jw,
	 task t,
	 circuit c,
     NOTES NTS,
     data_ext.asr_detail det,
     NPA_NXX NPA 
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and sr.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  AND SR.DOCUMENT_NUMBER = NTS.DOCUMENT_NUMBER (+)
  AND SR.DOCUMENT_NUMBER = DET.DOCUMENT_NUMBER (+)
  AND ASR.NPA = NPA.NPA (+)
  and asr.nxx = npa.nxx (+)
  and to_char(t.actual_completion_date,'yyyymm') = '201712'    --Current Reporting Month 
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','T','M')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
  AND SR.DOCUMENT_NUMBER > '1000000' 	
  and sr.acna in ('ATX','AAV','SBB','SBZ','SUV','TPM','AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   		      'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN',
				  'BSM','CBL','CCB','CDA','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO',
			      'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL',
				  'HGN','HLU','HNC','HTN','IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA',
			      'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB',
				  'MWZ','NBC','NWW','OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN',
				  'SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD',
				  'VRA','WBT','WGL','WLG','WLZ','WVO','WWC','NHO')
group by sr.document_number, asr.request_type, t.actual_completion_date, jeopardy_type_cd, build_iof, build_osp, 
         eusa_sec_sei, npa.exchange_area_clli, OSP_BDT_REQD, OSPREVW_BDT_REQD, COEREVW_BDT_REQD, COEREVWA_BDT_REQD, COEREVWZ_BDT_REQD
)
) a, jeopardy_type b     
where a.jeop = b.jeopardy_reason_code(+) 
  and a.jeop_type = b.jeopardy_type_cd(+)
 --and icsc not in ('RT01')  --Removed starting August 2016      
 and (supp <> 1 or supp is null) 
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders  
order by 1;





select a.docno, req, act, build, build_iof, build_osp,  
       case when icsc in ('GT10','GT11') and ctf_init < init then ctf_init else init end init,
       clean, dd, comp_dt, dd_comp, nc, prod, a.pon, ckt, icsc,  
       acna, comp, jeop, miss_reason, proj, state, region, product, 
       case when product in ('ATX DS3','ATX OCN') then 'ATX DS3 OCN'
            when product in ('ATX Ethernet UNI','ATX Ethernet Pop to Prem','ATX Ethernet Combo') then 'ATX UNI COMBO'
            when product = 'MOB Ethernet EVC' and act = 'N' then 'MOB EVC New'
            when product = 'MOB Ethernet UNI' and act = 'N' then 'MOB UNI New'
            when product = 'MOB Ethernet EVC' and act = 'C' then 'MOB EVC Change'
            when product = 'MOB Ethernet UNI' and act = 'C' then 'MOB UNI Change'
            else product end product2,
       bdw, OSP_BDT_REQD, OSPREVW_BDT_REQD, COEREVW_BDT_REQD, COEREVWA_BDT_REQD, COEREVWZ_BDT_REQD, DD_MET
       --case when icsc in ('GT10','GT11') and ctf_init < init then comp_dt-ctf_init else comp_dt-init end "INIT TO COMP", 
       --comp_dt-clean "CLEAN TO COMP"
from attpr a
where (product not like '%ESO%'
and product <> 'EXCLUDE');
     
	 
	 





