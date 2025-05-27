

select distinct sali.document_number doc_no, trunc(sali.dt_sent) DT_RCVD, sano||' '||sasn||' '||SATH address, city, substr(state,1,2) state, zip, 
       sr.pon, acna, first_ecckt_id, asr.desired_due_date due_date, 
       service_and_product_enhanc_cod spec, promotion_nbr pnum, variable_term_id vta, ASR.NETWORK_CHANNEL_SERVICE_CODE, nco.description, 
       sum(cabs_usoc_amt) MRC
from data_ext.asr_sali sali, serv_req sr, access_service_request asr, network_channel_option nco, 
     access_billing_circuit_data abcd, ACCESS_BILLING_CKT_LOC_USOCS abclu
where sali.document_number = sr.document_number
and sali.document_number = asr.document_number (+)
and asr.network_channel_service_code = nco.network_channel_service_code
and asr.network_channel_option_code = nco.network_channel_option_code
and sr.document_number = abcd.document_number
and abcd.cabs_circuit_id = abclu.cabs_circuit_id
and to_char(sali.dt_sent,'yyyymmdd') >= '20230901' -- Change monthly to first day of month   
and substr(ASR.ACTIVITY_INDICATOR,1,1) = 'N'
and ASR.NETWORK_CHANNEL_SERVICE_CODE not in ('HC','HF')
and (sr.supplement_type <> '1' or sr.supplement_type is null)
and acna||sano||zip in (
'GIM44725404'
)
group by sali.document_number, sali.dt_sent, sano, sasn, SATH, city, state, zip, 
       sr.pon, acna, first_ecckt_id, asr.desired_due_date, 
       service_and_product_enhanc_cod, promotion_nbr, variable_term_id, ASR.NETWORK_CHANNEL_SERVICE_CODE, nco.description
order by 8,3
;

;

