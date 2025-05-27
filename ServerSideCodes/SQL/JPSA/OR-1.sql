select isccode, ccna, pon, version, request_date, response_date,state,                    
       prod, NC, acna, ckt, spec                    
   from (                           
select isccode, ccna, pon, version, status, request_date, response_date, reqtype, act, document_number,                    
       CASE WHEN STATE IS NOT NULL THEN state                     
            WHEN ISCCODE = 'SN01' THEN 'CT' ELSE NPASTATE END STATE,                    
       case when nc = 'HC' then 'DS1'                    
       when nc = 'HF' then 'DS3'                    
       when evc_ind ='A' then 'Ethernet-EVC'                    
       when evc_ind = 'B' then 'Ethernet-Combo'                    
       when substr(nc,1,1) in ('V') then 'Ethernet-EVC'                    
       when substr(nc,1,1) in ('K') then 'Ethernet-UNI'                    
       when substr(nc,1,2) = 'SN' then 'Ethernet-NNI'                    
       when substr(nc,1,1) in ('X','L') then 'DS0'                    
       when substr(nc,1,1) = 'O' then 'OCN'                    
       when substr(ckt,4,1) = 'O' then 'OCN'                    
       when substr(ckt,4,2) in ('HC','HX','DH') then 'DS1'                    
       when substr(ckt,4,2) = 'HF' then 'DS3'                    
       when substr(ckt,4,1) in ('V') then 'Ethernet-EVC'                    
       when substr(ckt,4,1) in ('K') then 'Ethernet-UNI'                    
       when substr(ckt,4,2) in ('SX') then 'Ethernet-NNI'                    
       when substr(ckt,4,1) in ('X','L') then 'DS0'                    
       when substr(ckt,7,2) = 'T1' then 'DS1'                    
       when substr(ckt,1,2) = 'T1' then 'DS1'                    
       when substr(ckt,1,2) = 'T-' then 'DS1'                    
       when substr(ckt,1,2) = 'T.' then 'DS1'                    
       when substr(ckt,7,2) = 'T3' then 'DS3'                    
       when substr(ckt,1,2) = 'T3' then 'DS3'                    
       when substr(ckt,7,1) = 'O' then 'OCN'                    
       else 'UNK' end prod,                     
       NC, acna, ckt, spec, BDT_CLOSE, UNE                    
   from (                         
select isccode, ccna, pon, version, status, request_date, response_date, reqtype, act, state, acna, b.document_number, UNE,                    
       CASE WHEN NC IS NOT NULL THEN NC ELSE SVC_TYPE END NC,                    
       case when ckt is not null then ckt else ckt2 end ckt,                    
       SPEC, substr(exchange_area_clli,5,2) npastate, EVC_IND,
       MAX(TJW.jeopardy_reason_code) KEEP (DENSE_RANK LAST ORDER BY TJW.LAST_MODIFIED_DATE) JEOP_CODE,                     
       MAX(TJW.date_closed) KEEP (DENSE_RANK LAST ORDER BY TJW.LAST_MODIFIED_DATE) BDT_CLOSE                   
   FROM ( 
--                        
select isccode, a.ccna, a.pon, version, a.status, request_date, response_date, reqtype, activity, state,                    
       max(sr.document_number) KEEP (DENSE_RANK FIRST ORDER BY SR.LAST_MODIFIED_DATE) document_number,                     
       MAX(CIR.SERVICE_TYPE_CODE) KEEP (DENSE_RANK FIRST ORDER BY CIR.LAST_MODIFIED_DATE) SVC_TYPE,                    
       MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NC,                      
       max(sr.related_pon) keep (dense_rank last order by sr.last_modified_date) rpon,                    
       max(sr.acna) keep (dense_rank last order by sr.last_modified_date) acna,                    
       max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,                    
       MAX(ASR.IC_CIRCUIT_REFERENCE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) ckt2,                    
       MAX(ASR.ACTIVITY_INDICATOR) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) ACT,                    
       MAX(ASR.ACCESS_PROV_SERV_CTR_CODE2) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) ASC_EC,                    
       MAX(asr.service_and_product_enhanc_cod) KEEP (dense_rank last ORDER BY asr.last_modified_date) SPEC,                    
       MAX(ASR.EVC_IND) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) EVC_IND,                    
       MAX(ASR.UNBUNDLED_NETWORK_ELEMENT) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) UNE,                    
       MAX(ASR.NPA) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NPA,                    
       MAX(ASR.NXX) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NXX                    
from (                    
select isccode, ccna, pon, version, 'Confirmed' status, min(submitteddatetime) request_date,                     
min(updatedatetime) response_date, reqtype, activity, requeststate state                     
from stg_vfo.orderhistoryinfo_thist                    
where orderstatus in ('Confirmed_Submitted','Confirmed_Sent')                    
and to_char(updatedatetime,'yyyymm') = '202312'                    
and isccode <> 'FTRORD'                    
and ccna not in ('FLR','ZZZ','ZTK','CUS')                    
and substr(reqtype,1,1) in ('E','S') 
and requeststate in ('FL','CA')                   
group by isccode, ccna, pon, version, reqtype, activity, requeststate                   
) a,                     
  stg_m6.serv_req_thist sr,                    
  stg_m6.accs_svc_request_thist asr,                      
  stg_m6.serv_req_ckt_thist src,                     
  stg_m6.circuit_thist cir                      
where a.pon = sr.pon   
and a.ccna = sr.ccna                 
and sr.document_number = asr.document_number                    
and sr.document_number = src.document_number (+)                    
and SRC.CIRCUIT_DESIGN_ID = CIR.CIRCUIT_DESIGN_ID (+)                                      
group by isccode, a.ccna, a.pon, version, a.status, request_date, response_date, reqtype, activity, state 
--                   
) b, stg_m6.npa_nxx npa, stg_m6.task_jeopardy_whymiss_thist tjw                    
where b.npa = npa.npa (+)                    
and b.nxx = npa.nxx (+) 
and b.document_number = tjw.document_number (+) 
and jeopardy_reason_code (+) in ('CA07','1J')                   
and act in ('N','C','D','M','T')
group by isccode, ccna, pon, version, status, request_date, response_date, reqtype, act, state, acna, b.document_number, UNE,                    
       NC, SVC_TYPE, ckt, ckt2,spec, exchange_area_clli, evc_ind                    
))                    
where UNE = 'Y'                    
and bdt_close is null                    
and (ACNA NOT IN ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',                    
                  'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ','XYY') OR ACNA IS NULL)                    
and prod <> 'UNK'                    
and state in ('CA','FL')                    
order by 8;                    
