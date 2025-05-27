

select document_number, drec,  
		nc, icsc, data.acna, cl.type,
		case when state is not null then state 
            when pri is not null then pri
			else sec end state 
from (		
select aud.document_number,  
       max(asr.date_received) keep (dense_rank last order by asr.last_modified_date) drec,
	   max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc,   
	   max(access_provider_serv_ctr_code) icsc, 
	   max(sr.acna) acna,    
	   substr(max(clli_code),5,2) state, 
	   max(secloc_state) sec, 
	   max(priloc_state) pri,
	   max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) first_ckt
from casdw.asr_user_data aud, 
     casdw.access_service_request asr,
	 casdw.serv_req sr,
	 casdw.network_location nl,
	 casdw.design_layout_report dlr
where aud.document_number = asr.document_number
  and aud.document_number = sr.document_number(+)
  and asr.location_id = nl.location_id(+)
  and aud.document_number = dlr.document_number (+)
  and to_char(asr.date_received,'YYYYMM') in ('201201','201202') 
  and asr.request_type in ('S','E')
  and asr.activity_indicator in ('N')
  and (substr(asr.network_channel_service_code,1,1) in ('L','X') or substr(asr.network_channel_service_code,1,2) = 'HC')
  and asr.order_type = 'ASR'
group by aud.document_number
) data, carrier_list cl
where data.acna = cl.acna(+)

)
)where icsc not in ('RT01','CU03','CZ02')

