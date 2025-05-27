select isccode, ccna, pon, version, request_date, response_date, state, svc_type, nc,                        							
case when ckt is not null then ckt else ckt2 end circuit,                        							
act, spec, une,                        							
case when nc = 'HC' and SPEC = 'UNB1OT' then '3564' 
     when svc_type = 'HC' and SPEC = 'UNB1OT' then '3564'                       							
     when nc = 'HF' and SPEC = 'UNB1OT' then '3561'                        							
     when nc = 'HC' and SPEC = 'UNBALL' then '3605' 
     when svc_type = 'HC' and SPEC = 'UNBALL' then '3605'                       							
     when nc = 'HF' and SPEC = 'UNBALL' then '3606'                        							
     else null end code                             							
from (                        							
select isccode, a.ccna, a.pon, version, request_date, response_date, reqtype, state,                        							
       max(sr.document_number) KEEP (DENSE_RANK FIRST ORDER BY SR.LAST_MODIFIED_DATE) document_number,                         							
       MAX(CIR.SERVICE_TYPE_CODE) KEEP (DENSE_RANK FIRST ORDER BY CIR.LAST_MODIFIED_DATE) SVC_TYPE,                        							
       MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) NC,
       max(sr.ccna) keep (dense_rank last order by sr.last_modified_date) sr_ccna,                        							
       max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,                        							
       MAX(ASR.IC_CIRCUIT_REFERENCE) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) ckt2,                        							
       MAX(ASR.ACTIVITY_INDICATOR) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) ACT,                        							
       MAX(asr.service_and_product_enhanc_cod) KEEP (dense_rank last ORDER BY asr.last_modified_date) SPEC,                        							
       MAX(ASR.UNBUNDLED_NETWORK_ELEMENT) KEEP (DENSE_RANK LAST ORDER BY ASR.LAST_MODIFIED_DATE) UNE                        							
from (                       							
select isccode, ccna, pon, version, min(submitteddatetime) request_date,                         							
min(updatedatetime) response_date, reqtype, activity, requeststate state                         							
from stg_vfo.orderhistoryinfo_thist                        							
where orderstatus in ('Clarification-Errors_Submitted')                        							
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
and ASR.UNBUNDLED_NETWORK_ELEMENT = 'Y'                        							
group by isccode, a.ccna, a.pon, version, request_date, response_date, reqtype, state                        							
)                        							
where state in ('CA','FL')                        							
order by 7,2,3,4; 							


