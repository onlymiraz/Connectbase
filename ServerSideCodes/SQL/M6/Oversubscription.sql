select distinct sr.document_number, sr.pon, sr.supplement_type, sr.acna, sr.activity_ind, evc_ind, c.circuit_design_id, c.exchange_carrier_circuit_id, 
       aud.billing_uni_ckt, t.actual_completion_date, els.BANDWIDTH, els.BANDWIDTH_UOM, c2.circuit_design_id 
from serv_req sr, access_service_request asr, asr_user_data aud, service_request_circuit src, circuit c, task t, EVC_UNI_MAP EUM, EVC_LVL_SERV ELS, circuit c2
where sr.document_number = asr.document_number
  and sr.document_number = aud.DOCUMENT_NUMBER
  and sr.document_number = src.DOCUMENT_NUMBER
  and src.circuit_design_id = c.circuit_design_id 
  and sr.document_number = t.DOCUMENT_NUMBER
  and sr.document_number = eum.DOCUMENT_NUMBER
  AND EUM.DOCUMENT_NUMBER = ELS.DOCUMENT_NUMBER (+)
  AND EUM.EVC_UNI_MAP_ID = ELS.EVC_UNI_MAP_ID(+)
  and billing_uni_ckt = c2.exchange_carrier_circuit_id (+)
  and t.task_type = 'PRET2U'
  and t.task_status = 'Complete'
  and aud.billing_uni_ckt is not null
  and sr.activity_ind in ('N','C')
  and evc_ind in ('A')
  and (sr.supplement_type <> 1 or sr.supplement_type is null)
  --and to_char(asr.date_received,'yyyymmdd') = substr((TO_CHAR(SYSDATE-1,'YYYYMMDD')),1,8)
  and to_char(asr.date_received,'yyyymm') = '202203' 
  --and sr.document_number = '3713897'
order by 1
;

select * from evc_lvl_serv
where document_number = '3713897';

select * --exchange_carrier_circuit_id, rate_code, vir_circuit, vir_rate_code, virt_status, ca_cir, ca_cir_uom, sum_cir_evc
from team_oss.MV_UNI_EVC_DETAIL
where circuit_design_id = '4656345';
--where document_number = '3713897';