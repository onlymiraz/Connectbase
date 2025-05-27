select c.docno, comp_dt, c.pon, ckt, state, region, product
from (
select document_number docno, comp_dt, pon, ckt, state, prod, act, company,
       case WHEN STATE IN ('CT','NY','PA','OH','WV','MD','VA') then 'East'
            WHEN STATE IN ('IA','IL','IN','MI','MN','NE','WI','KY','TX') then 'Midwest'
            WHEN STATE IN ('AL','FL','GA','MS','NC','SC','TN') then 'South'
            WHEN STATE IN ('CA','AZ','NM','NV','UT','OR','WA','ID','MT') then 'West'
            ELSE 'Unknown' END REGION,        
       case when company = 'ATX' and prod = 'DS1' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX DS1'
            when acna = 'TPM' and prod = 'DS1' and substr(pon,4,1) in ('P','Y') then 'ATX DS1'
            when acna in ('SBB','SBZ','AAV','SUV') and prod = 'DS1' then 'ATX DS1'
            when company = 'ATX' and prod = 'DS1' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'X' then 'ATX ESO DS1'
            when company = 'ATX' and prod = 'DS3' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX DS3'
            when acna = 'TPM' and prod = 'DS3' and substr(pon,4,1) in ('P','Y') then 'ATX DS3'
            when acna in ('SBB','SBZ','AAV','SUV') and prod = 'DS3' then 'ATX DS3'
            when company = 'ATX' and prod = 'DS3' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'X' then 'ATX ESO DS3'
            when company = 'ATX' and prod like 'OC%' and substr(pon,3,1) = 'S' and substr(pon,4,1) = '0' then 'ATX'||' '||prod
            when company = 'ATX' and prod like 'OC%' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'X' then 'ATX ESO'||' '||prod
            when company = 'ATX' and prod ='DS0' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'X' then 'ATX ESO DS0'
            when company = 'ATX' and substr(nc,1,1) = 'O' and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'R' then 'ATX A-Ring'
            when company = 'ATX' and substr(nc,1,1) in ('H','O') and substr(pon,3,1) = 'S' and substr(pon,4,1) = 'A' then 'ATX A-Ring SCI' 
            when company = 'ATX' and prod = 'Ethernet' and evc_ind = 'B' then 'ATX Ethernet Combo'
            when company = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'E' and SEI = 'Y' then 'ATX Ethernet UNI'
            when company = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'S' and sei = 'Y' then 'ATX Ethernet Pop to Switch'
            when company = 'ATX' and prod = 'Ethernet' and substr(nc,1,1) = 'K' and req = 'S' and sei is null then 'ATX Ethernet Pop to Prem'
            when company = 'ATX' and prod = 'Ethernet' and evc_ind = 'A' then 'ATX Ethernet VLAN'
            when company = 'ATX' and prod = 'Ethernet' and substr(pon,4,1) = 'V' then 'ATX Ethernet VLAN'    
            when company = 'ATX' and prod = 'Ethernet' and substr(pon,4,1) = 'C' then 'ATX Ethernet Combo'
            when acna = 'ATX' and substr(pon,3,1) = 'H' then 'ATX IOF'  
            else 'EXCLUDE' end product        
from (
select document_number, dd_comp, accept_dt, 
       case when dd_comp is null and accept_dt > clean then Accept_dt
            when Accept_dt is null then dd_comp
            when Accept_dt <= dd_comp and accept_dt > clean then Accept_dt 
            else dd_comp end comp_Dt, 
       case when nc = 'HC' then 'DS1'
            when nc = 'HF' then 'DS3'
            when substr(nc,1,1) in ('L','X') then 'DS0'
            when nc in ('OB','OD','OF','OG') then 'OCN'
            when substr(nc,1,1) in ('K','V') then 'Ethernet'
            when substr(nc,1,2) in ('SN') then 'Ethernet'
            when substr(ckt,3,2) in ('/K','/V') then 'Ethernet'
            else ' ' end Prod,      
        pon, acna, 
        case when acna in ('ATX','AAV','SBB','SBZ','SUV','TPM','LOA','AVA','AYA') then 'ATX' else 'MOB' end company, 
        state, sei, evc_ind, act,
        supp, ckt, req, nc
from (
select sr.document_number, 
       asr.request_type req,  
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) clean, 
       max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD,
       max(aud.ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt,
       trunc(t.actual_completion_date)  DD_comp,
       max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc, 
       max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon, 
       max(sr.acna) acna,  
       max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act,   
       max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
       max(asr.evc_ind) keep (dense_rank last order by asr.last_modified_date) evc_ind,
       max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
       max(asr.switched_ethernet_indicator) keep (dense_rank last order by asr.last_modified_date) sei, 
       max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
       max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx,
       substr(npa.exchange_area_clli,5,2) state
from asr_user_data aud, 
     access_service_request asr,
     serv_req sr,
     task t,
     circuit c,
     NPA_NXX NPA 
where sr.document_number = asr.document_number
  and sr.document_number = aud.document_number(+)
  and sr.first_ecckt_id = c.exchange_carrier_circuit_id (+) --added join before the Feb 2019 data month  
  and sr.document_number = t.document_number
  AND ASR.NPA = NPA.NPA (+)
  and asr.nxx = npa.nxx (+)
  and to_char(t.actual_completion_date,'yyyymm') = '201906'    --One month in Arrear Reporting Month 
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N')
  and asr.order_type = 'ASR'
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
                  'VRA','WBT','WGL','WLG','WLZ','WVO','WWC','NHO','LOA','AVA','AYA')
group by sr.document_number, asr.request_type, t.actual_completion_date, npa.exchange_area_clli
) a
)     
 WHERE (supp <> 1 or supp is null) 
 and substr(ckt,7,1) <> 'U'  -- Removes UNE Orders  
) c
where (product not like '%ESO%'
and product <> 'EXCLUDE')
and company not in ('MOB');