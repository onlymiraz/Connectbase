select distinct docno, pon, act, ckt, uni, drec, dd, ddd, Comp_Dt, Prod, project, icsc, acna, expedite, state, 
       case WHEN STATE IN ('AZ','NV','NM','UT','WI','AL','FL','GA','MS','TN','NC','SC') THEN 'National'
			WHEN STATE IN ('MI','WI') THEN 'CENTRAL'
	        WHEN STATE IN ('IN','KY','AL','FL','GA','MS','TN') THEN 'MIDWEST'
       		WHEN STATE IN ('NY','PA','CT') THEN 'EAST'
			WHEN STATE IN ('IL','MO','OH','WV','MD','VA') THEN 'MID-ATLANTIC'
	  		WHEN STATE IN ('CA','OR','WA','ID','MT') THEN 'WEST'
	  		WHEN STATE IN ('AZ','NM','NV','UT','MN','SC','NC','IA','NE') THEN 'NATIONAL'
	  		ELSE 'Unknown' END REGION, npa, nxx,
       --CLLIZ, Orig_dd_status, 
       build_iof, build_osp
 from (      
select distinct document_number docno, pon, rpon, act, ckt, drec, dd, ddd, Comp_Dt, dd_comp dd_task_comp,  
       Prod, project, 
       icsc, acna, state, 
       clli_code, expedite,        
       case when (comp_dt <= DD or DD is null) then 'Met'
            when (comp_dt > DD and jeop in ('CU01','CU02','CU03','CU04','CU05')) then 'Met'
            else 'Miss' end Orig_DD_Status,
        npa, nxx, build_iof, build_osp, clliz, uni, mtso    
from (
select distinct data.document_number, trunc(drec) drec, dd, ddd, dd_comp, accept_dt, 
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
        pon, rpon, icsc, acna, project, clli_code, jeop, act,
        case when npa.exchange_area_clli is not null then substr(npa.exchange_area_clli,5,2)
             when clliz is not null then substr(clliz,5,2)
             else substr(cllia,5,2) end state,
        supp, ckt, expedite, data.npa, data.nxx, 
        CASE WHEN (SUBSTR(LTRIM(RUID01),4,2) not in ('KG','KS') OR SUBSTR(LTRIM(RUID02),4,2) in ('KG','KS')) THEN RUID01 ELSE RUID02 END UNI, 
        CASE WHEN (SUBSTR(LTRIM(RUID01),4,2) not in ('KG','KS') OR SUBSTR(LTRIM(RUID02),4,2) in ('KG','KS')) THEN RUID02 ELSE RUID01 END MTSO,
        substr(cllia,5,2) cllia, 
        substr(clliz,5,2) clliz2, clliz, 
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
     else null end build_iof, 
case when build_osp = '357' then '01-OSP - No Construction Required'
     when build_osp = '358' then '02-OSPMINOR - Loop Conditioning'
     when build_osp = '359' then '03-OSPMINOR - Doubler Installation'
     when build_osp = '360' then '04-OSPMAJOR - Constr-Copper Placing'
     when build_osp = '361' then '05-OSPMAJOR  -Fiber Placing/Fiber Splicing Work-Minor'
     when build_osp = '362' then '06-OSPMAJOR - Fiber Placing/Fiber Splicing <2,500'
     when build_osp = '363' then '07-OSPMAJOR - Fiber Placing/Fiber Splicing >2,500'
     when build_osp = '364' then '08-OSPMAJOR - Place FDP'
              else null end build_osp
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
       max(asr.related_pon) keep (dense_rank last order by asr.last_modified_date) rpon,
       max(access_provider_serv_ctr_code) icsc, 
       max(sr.acna) acna,  
       max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
       max(jeopardy_reason_code) keep (dense_rank last order by jw.last_modified_date) jeop,
       max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code, 
       max(substr(nl1.clli_code,1,6)) keep (dense_rank last order by nl1.last_modified_date) cllia,
       max(substr(nl2.clli_code,1,6)) keep (dense_rank last order by nl2.last_modified_date) clliz, 
       trunc(t.actual_completion_date-4/24) DD_COMP,
       max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
       max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
       max(expedite_indicator) keep (dense_rank last order by asr.last_modified_date) expedite,
       max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
       max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx,
       max(aud.build_iof) keep (dense_rank last order by aud.last_modified_date) build_iof, 
       max(aud.build_osp) keep (dense_rank last order by aud.last_modified_date) build_osp,
       evc1.rel_uni_ident RUID01, evc2.rel_uni_ident RUID02
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     network_location nl1,
     network_location nl2,
     task_jeopardy_whymiss jw,
     task t,
     circuit c,
     EVC_UNI_MAP EVC1,
	 EVC_UNI_MAP EVC2
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id
  and c.location_id = nl1.location_id(+)
  and c.location_id_2 = nl2.location_id(+)
  and sr.document_number = t.document_number
  and t.task_number = jw.task_number(+)
  AND SR.DOCUMENT_NUMBER = EVC1.DOCUMENT_NUMBER(+)
  AND SR.DOCUMENT_NUMBER = EVC2.DOCUMENT_NUMBER(+)
  AND (EVC1.UNI_REF_NBR = '01' OR EVC1.UNI_REF_NBR IS NULL)  
  AND (EVC2.UNI_REF_NBR = '02' OR EVC2.UNI_REF_NBR IS NULL)
  and to_char(t.actual_completion_date,'yyyy') = '2015'    --Current Reporting Month  
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C')
  and asr.order_type = 'ASR'
  and sr.acna = 'LGT'
  and jw.jeopardy_type_cd(+) = 'W' 
  and t.task_type = 'DD'
group by aud.document_number, asr.request_type, t.actual_completion_date, evc1.rel_uni_ident, evc2.rel_uni_ident
) data, 
  npa_nxx npa
  where data.npa = npa.npa (+)
    and data.nxx = npa.nxx (+)  
)
where icsc not in ('RT01','CU03','CZ02')
 and (supp <> 1 or supp is null) 
 and prod in ('Ethernet-UNI','Ethernet-EVC')                  
)                   
order by 9,1;


select * from notes
where document_number = '2275271';

select * from evc_uni_map
where document_number = '2179483';

select *
from data_ext.asr_evc;




