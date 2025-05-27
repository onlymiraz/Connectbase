--drop table attpr
--/

--create table attpr nologging nocache as

select *
from (
select docno, req, act, build, build_iof, build_osp,  
       case when icsc in ('GT10','GT11') and ctf_init < init then ctf_init else init end init,
       clean, dd, comp_dt, dd_comp, nc, prod, pnum, pon, ckt, icsc,  
       acna, comp, 
       case when dd_met = '1' and why_miss not in ('CU01','CU02','CU03','CU04','CU05','DS02','CA22','EX01','CU51','CU52','CU53','CU54','DS52','PM53') then null else why_miss end why_miss1,
       case when dd_met = '1' and why_miss not in ('CU01','CU02','CU03','CU04','CU05','DS02','CA22','EX01','CU51','CU52','CU53','CU54','DS52','PM53') then null else miss_reason end miss_reason1,
       proj, state, region, product, 
       case when product in ('ATX DS1','ATX DS3','ATX OCN') and act = 'N' then 'ATX TDM'
            when product in ('MOB DS1','MOB DS3','MOB OCN') then 'MOB TDM'
            when product in ('ATX Ethernet UNI','ATX Ethernet Pop to Prem','ATX Ethernet Combo') and act = 'N' then 'ATX UNI ALL'
            when product = 'ATX Ethernet VLAN' and act = 'C' then 'ATX EVC'
            when substr(product,1,12) = 'MOB Ethernet' and act in ('N','C','M') then 'MOB Ethernet'
            else 'Exclude' end product2,
       sei, bdw, DD_MET, 
       case when rtr = 'S' then 'Yes' else null end dlr
from (
select document_number docno, req, act, init, case when clean < init then init else clean end clean, clean ctf_init,
       dd, comp_dt, nc, prod, pon, pnum, ckt, icsc, acna, comp, dd_comp, sei,
       CASE WHEN WMRCA IS NOT NULL THEN wmrca ELSE WM END WHY_MISS, 
       CASE WHEN WMRCA IS NOT NULL THEN WMRCA_DESC ELSE WM_DESC END Miss_reason, 
       proj, state, 
	   case WHEN STATE IN ('CT','NY','PA','AL','FL','GA','MS','NC','SC','TN') then 'Eastern'
            WHEN STATE IN ('IA','IL','IN','MI','MN','NE','WI','KY','TX','OH','WV','MD','VA') then 'Central'
       		WHEN STATE IN ('CA','AZ','NM','NV','UT') then 'Western'
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
            when comp = 'ATX' and prod = 'Ethernet' and evc_ind = 'B' then 'ATX Ethernet Combo'
            when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'E' and SEI = 'Y' then 'ATX Ethernet UNI'
            when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'S' and sei = 'Y' then 'ATX Ethernet Pop to Switch'
            when comp = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'S' and sei is null then 'ATX Ethernet Pop to Prem'
            when comp = 'ATX' and prod = 'Ethernet' and evc_ind = 'A' then 'ATX Ethernet VLAN'
            when comp = 'ATX' and prod = 'Ethernet' and substr(pon,4,1) = 'V' then 'ATX Ethernet VLAN'    
			when comp = 'ATX' and prod = 'Ethernet' and substr(pon,4,1) = 'C' then 'ATX Ethernet Combo'
            when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'V' then 'MOB Ethernet EVC'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'K' and req = 'S' then 'MOB Ethernet MTSO'
			when comp = 'MOB' and prod = 'Ethernet' and substr(ckt,4,1) = 'K' and req = 'E' then 'MOB Ethernet UNI'
			when acna = 'ATX' and substr(pon,3,1) = 'H' then 'ATX IOF'  
			else 'EXCLUDE' end product, 
       CASE WHEN (COMP_DT <= DD OR DD IS NULL) THEN 1
            WHEN (COMP_DT > DD AND WMRCA IN ('CU01','CU02','CU03','CU04','CU05','DS02','CA22','EX01','CU51','CU52','CU53','CU54','DS52','PM53')) THEN 1
            WHEN (COMP_DT > DD AND WMRCA IS NULL AND WM IN ('CU01','CU02','CU03','CU04','CU05','DS02','CA22','EX01','CU51','CU52','CU53','CU54','DS52','PM53')) THEN 1
            ELSE 0 END DD_MET,     
       CASE WHEN BUILD_IOF LIKE '%IOFMINOR%' THEN 'MINOR BUILD'
            WHEN BUILD_IOF LIKE '%IOFMAJOR%' THEN 'MAJOR BUILD'
            WHEN BUILD_IOF LIKE '%IOFCOMPLEX%' THEN 'MAJOR BUILD'
            WHEN BUILD_OSP LIKE '%OSPMINOR%' THEN 'MINOR BUILD'
            WHEN BUILD_OSP LIKE '%OSPMAJOR%' THEN 'MAJOR BUILD'
            WHEN BUILD_OSP LIKE '%OSPCOMPLEX%' THEN 'MAJOR BUILD'
            ELSE 'NO BUILD' END BUILD,       
       build_iof, build_osp, bdw, rtr 		
from (
select document_number, trunc(clean) clean, dd, dd_comp, accept_dt, 
       case when dd_comp is null and accept_dt > clean then Accept_dt
	        when Accept_dt is null then dd_comp
	        when Accept_dt <= dd_comp and accept_dt > clean then Accept_dt 
	        else dd_comp end Comp_Dt, 
	   case when nc = 'HC' then 'DS1'
	        when nc = 'HF' then 'DS3'
            when substr(nc,1,2) in ('LX') then 'DS3'
			when substr(nc,1,1) in ('L','X') then 'DS0'
            when nc in ('OB','OD','OF','OG') then 'OCN'
			when substr(nc,1,1) in ('K','V') then 'Ethernet'
            when substr(nc,1,2) in ('SN') then 'Ethernet'
			when substr(ckt,3,2) in ('/K','/V') then 'Ethernet'
			when proj like 'ATTMOB-%' then 'Ethernet'
			else ' ' end Prod,	
       case when svc_cd in ('KD','KP') then '10M'
            when svc_cd in ('KE','KQ') then '100M'    			
            when svc_cd in ('KF','KR') then '1G'
            when svc_cd in ('KG','KS') then '10G'
            when svc_cd = 'VL' then 'EVC'
            when substr(ckt,4,1) = 'V' then 'EVC'
            else null end BDW,   	
		pon, icsc, acna, trunc(asr_init) init, 
		case when acna in ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM') then 'ATX' else 'MOB' end comp, 
		proj, WM, B.JEOPARDY_REASON_DESCRIPTION WM_DESC, wmrca, c.JEOPARDY_REASON_DESCRIPTION WMRCA_DESC,
        state, sei, act, evc_ind, pnum, 
		supp, ckt, req, nc, npa, rtr, 
       (SELECT UDCV.DISPLAY_VALUE FROM USER_DATA_CATEGORY_VALUES UDCV WHERE A.BUILD_IOF = UDCV.USER_DATA_CATEGORY_VALUE_ID) AS BUILD_IOF,
       (SELECT UDCV.DISPLAY_VALUE FROM USER_DATA_CATEGORY_VALUES UDCV WHERE A.BUILD_OSP = UDCV.USER_DATA_CATEGORY_VALUE_ID) AS BUILD_OSP     
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
	   max(jw.jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) wm,
       MAX(JWRCA.JEOPARDY_REASON_CODE) KEEP (DENSE_RANK LAST ORDER BY JWRCA.LAST_MODIFIED_DATE) WMRCA,
	   jw.jeopardy_type_cd jeop_type,
       jwrca.jeopardy_type_cd rca_jeop_type,    
	   max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
       max(asr.evc_ind) keep (dense_rank last order by asr.last_modified_date) evc_ind,
       max(asr.promotion_nbr) keep (dense_rank last order by asr.last_modified_date) pnum,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
	   build_iof, build_osp, 
       min(nts.last_modified_date) keep (dense_rank first order by nts.last_modified_date) asr_init,
       max(asr.switched_ethernet_indicator) keep (dense_rank last order by asr.last_modified_date) sei, 
       max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
       max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
	   max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx,
       substr(npa.exchange_area_clli,5,2) state,
       substr(det.rtr,1,1) rtr 
from asr_user_data aud, 
     access_service_request asr,
	 serv_req sr,
	 task_jeopardy_whymiss jw,
     task_jeopardy_whymiss jwrca,
	 task t,
     task t2,
	 circuit c,
     NOTES NTS,
     data_ext.asr_detail det,
     NPA_NXX NPA 
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id (+) --added join before the Feb 2019 data month  
  and sr.document_number = t.document_number
  and sr.document_number = t2.document_number (+)
  and t.task_number = jw.task_number(+)
  and t2.task_number = jwrca.task_number(+)
  AND SR.DOCUMENT_NUMBER = NTS.DOCUMENT_NUMBER (+)
  AND SR.DOCUMENT_NUMBER = DET.DOCUMENT_NUMBER (+)
  AND ASR.NPA = NPA.NPA (+)
  and asr.nxx = npa.nxx (+)
  and to_char(t.actual_completion_date,'yyyymm') = '202212'    --Current Reporting Month 
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','M')
  and asr.order_type = 'ASR'
  and jw.jeopardy_type_cd(+) = 'W' 
  and jwrca.jeopardy_type_cd(+) = 'W'
  and t.task_type = 'DD'
  and t2.task_type (+) = 'RCA'
  AND SR.DOCUMENT_NUMBER > '1000000'
  and sr.acna in ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM',
                  'AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH',
	   		      'AMP','AWL','AWN','AWS','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','BWI','CBL','CCB',
				  'CDA','CEL','CEO','CEU','CFN','CGL','CIV','CIW','CKQ','CLQ','COW','CPF','CQW','CRF','CRJ','CSG','CSO',
			      'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','EST','ETP','ETX','FLA','FSC','FSI','FSV','GEE','GLV',
                  'GMB','GSL','HGN','HLU','HNC','HTN','HWC','IAS','IFP','IMP','IND','ISZ','IUW','JCR','JCT','LAA','LAC',
                  'LBH','LNZ','LSZ','MBN','MBQ','MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIR','MLA','MLZ','MMV',
                  'MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NHL','NHO','NSI','NWW','OAK','OCL','ORV','OSU','PCK','PFM',
                  'PIG','RAD','RMC','RMF','RRC','SBG','SBJ','SBM','SBN','SBT','SCU','SHI','SLL','SMC','SNP','SSL','STH',
                  'SUF','SWC','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','TZV','UMT','VGB','VGD','VRA','WBT','WGL',
                  'WLG','WLZ','WVO','WWC','ZAQ','ZAW','ZBM','ZCI','ZWO')
group by sr.document_number, asr.request_type, t.actual_completion_date, jw.jeopardy_type_cd, jwrca.jeopardy_type_cd, build_iof, build_osp, 
         eusa_sec_sei, npa.exchange_area_clli, det.rtr
) a, jeopardy_type b, jeopardy_type c     
  where a.WM = b.jeopardy_reason_code(+) 
  and a.jeop_type = b.jeopardy_type_cd(+)
  and a.wmrca = c.jeopardy_reason_code(+) 
  and a.rca_jeop_type = c.jeopardy_type_cd(+)
)     
 WHERE (supp <> 1 or supp is null) 
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders  
))
where product2 not in ('Exclude','ATX EVC','MOB TDM')
order by 11;




   
	 
