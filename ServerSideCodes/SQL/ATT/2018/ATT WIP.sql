select DISTINCT docno, pon, req, act, acna, comp, ckt, init, clean, dd, asr_conf, accept_dt, dd_comp,
       state, region, sei, evc_ind, prod, bdw, product, task_at_jeop, jeop_code
from (      
select document_number docno, pon, req, act, acna, comp, init, clean, dd, accept_dt, dd_comp, asr_conf, state,
       min(ckt) ckt, 
       case WHEN STATE IN ('CT','NY','PA','OH','WV','MD','VA') then 'East'
            WHEN STATE IN ('IA','IL','IN','MI','MN','NE','WI','KY','TX') then 'Midwest'
            WHEN STATE IN ('AL','FL','GA','MS','NC','SC','TN') then 'South'
               WHEN STATE IN ('CA','AZ','NM','NV','UT') then 'West'
              ELSE 'Unknown' END REGION,
       sei, evc_ind, prod, bdw,         
       case when comp = 'ATX' and prod in ('DS1','DS3','OCN') and act = 'N' then 'ABS TDM'
            when comp = 'ATX' and prod = 'Ethernet' and BDW in ('10M','100M','1G') and act = 'N' then 'ABS Ethernet UNI'
            when comp = 'MOB' and evc_ind = 'B' and BDW = 'EVC' then 'EXCLUDE'
            when comp = 'MOB' --and prod = 'Ethernet' 
                 then 'MOB All Orders'
            else 'EXCLUDE' end product,
       task_at_jeop, JEOP_CODE                  
from (
select a.document_number, trunc(asr_init) init, trunc(clean) clean, dd, accept_dt, dd_comp, asr_conf,   
       case when nc = 'HC' or svc_cd = 'HC' or svc_cd = 'T1' then 'DS1'
            when nc = 'HF' or svc_cd = 'HF' or svc_cd = 'T3' then 'DS3'
            when nc in ('OB','OD','OF','OG') or substr(svc_cd,1,2) = 'OC' then 'OCN'
            when substr(nc,1,1) in ('K','V') then 'Ethernet'
            when substr(svc_cd,1,1) in ('K','V') then 'Ethernet'
            when substr(ckt,3,2) in ('/K','/V') then 'Ethernet'
            else ' ' end Prod,    
       case when evc_ind = 'A' then 'EVC'
            when svc_cd in ('KD','KP') then '10M'
            when svc_cd in ('KE','KQ') then '100M'                
            when svc_cd in ('KF','KR') then '1G'
            when svc_cd in ('KG','KS') then '10G'
            when svc_cd = 'VL' then 'EVC'
            when nc in ('KD','KP') then '10M'
            when nc in ('KE','KQ') then '100M'                
            when nc in ('KF','KR') then '1G'
            when nc in ('KG','KS') then '10G'
            else null end BDW,       
        pon, acna, 
        case when acna in ('ATX','AAV','SBB','SBZ','SUV','TPM','LOA','AVA','AYA') then 'ATX' else 'MOB' end comp,
        CASE WHEN GA_STATE = STATE THEN GA_STATE
             WHEN STATE IS NOT NULL THEN STATE
             ELSE GA_STATE END STATE, 
        sei, act, UNE, evc_ind, req, svc_cd, nc, ckt,
        listagg(t3.task_type, ' / ') WITHIN GROUP (ORDER BY t3.task_type) as task_at_jeop,
        listagg(TJW.JEOPARDY_REASON_CODE, ' / ') WITHIN GROUP (ORDER BY t3.task_type) as JEOP_CODE
from (
select sr.document_number, 
       asr.request_type req, 
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) clean, 
       max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD,
       max(aud.ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
       trunc(t.actual_completion_date)  DD_COMP,
       trunc(t3.actual_completion_date)  ASR_CONF,
       max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc,
       MAX(ASR.UNBUNDLED_NETWORK_ELEMENT) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) UNE,             
       max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,  
       max(access_provider_serv_ctr_code) icsc, 
       max(sr.acna) acna,  
       max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act,    
       max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
       max(asr.evc_ind) keep (dense_rank last order by asr.last_modified_date) evc_ind,
       C.EXCHANGE_CARRIER_CIRCUIT_ID CKT,
       min(nts.last_modified_date) keep (dense_rank first order by nts.last_modified_date) asr_init,
       max(asr.switched_ethernet_indicator) keep (dense_rank last order by asr.last_modified_date) sei, 
       max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
       max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
       max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx,
       substr(npa.exchange_area_clli,5,2) state,
       GAI.INSTANCE_VALUE_ABBREV GA_STATE 
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     ASAP.SERVICE_REQUEST_CIRCUIT SRC, 
     task t,
     task t2,
     task t3,
     circuit c,
     NPA_NXX NPA,
     SR_LOC LOC,
     ADDRESS ADDR,
     GA_INSTANCE GAI,
     NOTES nts 
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  AND SR.DOCUMENT_NUMBER = SRC.DOCUMENT_NUMBER (+)
  AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+) 
  and sr.document_number = t.document_number (+)
  and sr.document_number = t2.document_number (+)
  and sr.document_number = t3.document_number (+)
  AND SR.DOCUMENT_NUMBER = NTS.DOCUMENT_NUMBER (+)
  AND ASR.NPA = NPA.NPA (+)
  and asr.nxx = npa.nxx (+)
  AND SR.DOCUMENT_NUMBER = LOC.DOCUMENT_NUMBER(+)
  AND LOC.ADDRESS_ID (+) IS NOT NULL
  AND LOC.ADDRESS_ID = ADDR.ADDRESS_ID (+)
  AND ADDR.ADDR_VALID_IND (+) = 'Y'
  AND ADDR.GA_INSTANCE_ID_STATE_CD = GAI.GA_INSTANCE_ID (+)
  AND GAI.GAT_TYPE_NM (+) = 'STATE'
  AND GAI.GAT_TYPE_COUNTRY_EXT_ID (+) = 47 
  AND T.ACTUAL_COMPLETION_DATE IS NULL 
  AND T2.ACTUAL_COMPLETION_DATE IS NULL
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N','C','D')
  and asr.order_type = 'ASR' 
  and t.task_type = 'DD'
  and t2.task_type(+) = 'CAD'
  and t3.task_type(+) = 'ASR-CONF'
  AND SR.DOCUMENT_NUMBER  > '1100000'
  and sr.acna in ('ATX','AAV','SBB','SBZ','SUV','TPM','AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
                  'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BPN',
                  'BSM','CBL','CCB','CDA','CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO',
                  'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV','GSL',
                  'HGN','HLU','HNC','HTN','IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ','MCA',
                  'MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB',
                  'MWZ','NBC','NWW','OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN',
                  'SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD',
                  'VRA','WBT','WGL','WLG','WLZ','WVO','WWC','NHO','LOA','AVA','AYA')
group by sr.document_number, asr.request_type, t.actual_completion_date, t3.actual_completion_date, npa.exchange_area_clli,
         C.EXCHANGE_CARRIER_CIRCUIT_ID, GAI.INSTANCE_VALUE_ABBREV
) a,
  task_jeopardy_whymiss tjw,
  task t3
where a.document_number = tjw.document_number (+)
  and tjw.task_number = t3.task_number (+) 
  AND TJW.JEOPARDY_TYPE_CD (+) = 'J'
  AND TJW.DATE_CLOSED (+) IS NULL 
  and (supp <> 1 or supp is null) 
  and une <> 'Y'
group by a.document_number, asr_init, clean, dd, accept_dt, dd_comp, nc, svc_cd, ckt, evc_ind,  
        pon, acna, GA_STATE, STATE, sei, act, UNE, evc_ind, req, svc_cd, nc, ckt, asr_conf  
)
group by document_number, pon, req, act, acna, comp, init, clean, dd, accept_dt, dd_comp, state, sei, evc_ind, 
         prod, bdw, task_at_jeop, JEOP_CODE, asr_conf
)
where product <> 'EXCLUDE'
order by 8, 1
;





