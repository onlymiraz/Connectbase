select ban, acna, customer, state, lata, null usid, pnum, address, year, dd_comp, city, uni, mtso, evc, null unihold,   
       null mtsohold, null evchold, act, bdw, los, uni_spec, mtso_spec, A_END_ADDRESS, uni1full, mtso_full, evc_full, gp.type, 
       null sp1, null sp2, null sp3, c30.EXCHANGE_CARRIER_CIRCUIT_ID, c30.circuit_design_id, c30.status, 
       nl30.clli_code, nl30.location_name, nl30.h_coordinate, nl30.v_coordinate, 
       nl31.clli_code, nl31.location_name, nl31.h_coordinate, nl31.v_coordinate,
       max(ccv31.ca_value) keep (dense_rank last order by ccv31.last_modified_date) A_NODE_IP, 
       max(ccv34.ca_value||ccv34.ca_value_uom) keep (dense_rank last order by ccv34.last_modified_date) bit_rate,
       null sp4, c40.EXCHANGE_CARRIER_CIRCUIT_ID, c40.circuit_design_id, c40.status, 
       nl40.clli_code, nl40.location_name, nl40.h_coordinate, nl40.v_coordinate, 
       nl41.clli_code, nl41.location_name, nl41.h_coordinate, nl41.v_coordinate,
       max(ccv41.ca_value) keep (dense_rank last order by ccv41.last_modified_date) A_NODE_IP, 
       max(ccv44.ca_value||ccv44.ca_value_uom) keep (dense_rank last order by ccv44.last_modified_date) bit_rate
from (
select distinct ban, acna, 
       case when acna = 'ATX' then 'ATX BADGERNET'
            ELSE NULL END CUSTOMER,
       state, lata, pnum, 
       address, to_char(dd_comp,'YYYY') year, 
       dd_comp, city, uni, mtso, evc,  
        act, bdw, los, uni_spec, mtso_spec, 
       A_END_ADDRESS, uni1full, uni2full MTSO_FULL, ckt_full EVC_FULL,
       case when icsc in ('GT10','GT11') then 'CTF' else 'Legacy' end type
from (        
select b.ban, b.acna, substr(sali.state,1,2) state, 
       b.lata, b.ICSC, los, pnum, uni_spec, mtso_spec,
       SANO||' '||SASD||' '||SASN||' '||SATH address,
       null year,
       null build_year,
       null program,
       null sche2e,
       null acte2e,
       null schread,
       b.dd_comp,
       null UNIhold,
       null EVChold,
       null MTSOhold,
       sali.city,
       b.UNI UNI,
       b.MTSO,
       b.EVC, 
       b.act, b.bdw, uni2, mtso2,
       length(b.mtso) mtsosize,
       A_END_ADDRESS, 
       replace(uni1full, '.', '/') uni1full,
       replace(uni2full, '.', '/') uni2full,
       replace(ckt_full, '.', '/') ckt_full 
from (
    select sr2.document_number,  
       max(co2.lata_number) keep (dense_rank last order by co2.last_modified_date) lata, 
       ICSC, los, pnum,
       ban, a.acna, dd_comp, UNI, MTSO,
       EVC, act, bdw, 
       uni2, mtso2,
       max(asr2.service_and_product_enhanc_cod) keep (dense_rank last order by asr2.last_modified_date) uni_spec,
       max(asr3.service_and_product_enhanc_cod) keep (dense_rank last order by asr3.last_modified_date) mtso_spec,
       A_END_ADDRESS, uni1full, uni2full, ckt_full 
    from (
       select ban, acna, lata, dd_comp, ICSC, los, pnum,
           case when substr(uni1,4,2) <> 'KG' then uni1
           else uni2 end UNI,
           case when substr(uni1,4,2) = 'KG' then uni1
           else uni2 end MTSO,
           ckt EVC, document_number, act, bdw,
           case when substr(uni1,4,2) <> 'KG' then evcmp1
           else evcmp2 end UNI2,
           case when substr(uni1,4,2) = 'KG' then evcmp1
           else evcmp2 end MTSO2,
        replace(addr_ln1,'MSAG ')||', '||addr_ln3 as A_END_ADDRESS, 
        uni1full, uni2full, ckt_full 
       from (
        select aud.document_number,
            max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon, 
            max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) project,
            min(ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) Accept_Dt, 
            trunc(t.actual_completion_date-4/24) DD_COMP,
            max(sr.acna) acna,  
            MAX(ASR.ACCESS_PROVIDER_SERV_CTR_CODE) keep (dense_rank last order by asr.last_modified_date) ICSC,
            max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act, 
            MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) keep (dense_rank last order by asr.last_modified_date) NC,
            max(aud.ban) keep (dense_rank last order by aud.last_modified_date) ban,
            MAX(asr.promotion_nbr) keep (dense_rank last order by asr.last_modified_date) pnum,
            max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
            regexp_replace(C.EXCHANGE_CARRIER_CIRCUIT_ID, '[^a-zA-Z0-9'']', '') CKT,
            C.EXCHANGE_CARRIER_CIRCUIT_ID ckt_full,
            max(co.lata_number) keep (dense_rank last order by co.last_modified_date) lata,
            evc.bdw,
            REGEXP_REPLACE(evc.ruid, '[^a-zA-Z0-9'']', '') uni1,
            REGEXP_REPLACE(evc2.ruid, '[^a-zA-Z0-9'']', '') uni2,
            REPLACE (evc.ruid, '.', '/') uni1full,
            REPLACE (evc2.ruid, '.', '/') uni2full,
            eum.evc_meet_point_id evcmp1,
            eum2.evc_meet_point_id evcmp2,
            max(addr2.addr_ln1) keep (dense_rank last order by addr2.last_modified_date) addr_ln1,
            max(addr2.addr_ln3) keep (dense_rank last order by addr2.last_modified_date) addr_ln3,     
            els.lvl_of_serv_nm los
        from asr_user_data aud, 
             access_service_request asr,
             serv_req sr,
             network_location nl2,
             task t,
             circuit c,
             central_office_exchange_area co,
             data_ext.asr_evc evc,
             data_ext.asr_evc evc2,
             evc_uni_map eum,
             evc_uni_map eum2,
             net_loc_addr nla2, 
             address addr2,
             evc_lvl_serv els,
             ASAP.SERVICE_REQUEST_CIRCUIT SRC
        where sr.document_number = asr.document_number
        and sr.document_number = aud.document_number(+)
        --and sr.first_ecckt_id = c.exchange_carrier_circuit_id
        and c.location_id = nl2.location_id(+)
        and sr.document_number = t.document_number
        and nl2.exchange_area_clli = co.exchange_area_clli (+)
        and sr.document_number = evc.document_number (+)
        and sr.document_number = evc2.document_number (+)
        and sr.document_number = eum.document_number (+)
        and sr.document_number = eum2.document_number (+)
        and c.location_id = nla2.location_id (+)
        and nla2.address_id = addr2.address_id (+)
        and sr.document_number = els.document_number (+)
        AND SR.DOCUMENT_NUMBER = SRC.DOCUMENT_NUMBER (+)
        AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+)
        and to_char(t.actual_completion_date,'yyyymmdd') >= '20200816'  
        and asr.request_type in ('S','E')
        and asr.activity_indicator in ('N','C','R')
        and asr.order_type = 'ASR' 
        and t.task_type = 'DD'
        and sr.acna in ('ATX')
        and evc_ind is not null
        and evc.uref = '01'
        and evc2.uref = '02'
        and eum.uni_ref_nbr = '01'
        and eum2.uni_ref_nbr = '02'
        --and els.lvl_of_serv_nm in ('RT','PD')
        --and sr.document_number = '2865582' --'2888506'
        and substr(asr.promotion_nbr,1,11) = 'EPATH301253'
        group by aud.document_number, asr.request_type, t.actual_completion_date, evc.ruid, evc2.ruid, 
        evc.bdw, eum.evc_meet_point_id, eum2.evc_meet_point_id, els.lvl_of_serv_nm, C.EXCHANGE_CARRIER_CIRCUIT_ID 
        )
       where (supp <> 1 or supp is null)
       ) a,
         serv_req sr2,
         access_service_request asr2, 
         circuit c2,
         network_location nl4, 
         central_office_exchange_area co2,
         serv_req sr3,
         access_service_request asr3
    where a.uni = regexp_replace(sr2.first_ecckt_id(+), '[^a-zA-Z0-9'']', '')
    and sr2.document_number = asr2.document_number (+)
    and sr2.first_ecckt_id = c2.exchange_carrier_circuit_id (+)
    and nl4.exchange_area_clli = co2.exchange_area_clli (+)
    and c2.location_id_2 = nl4.location_id (+)
    and a.mtso = regexp_replace(sr3.first_ecckt_id(+), '[^a-zA-Z0-9'']', '')
    and sr3.document_number = asr3.document_number (+)
    --and sr2.activity_ind (+) = 'N'
    group by sr2.document_number, ICSC, los, pnum, ban, a.acna, 
       dd_comp, UNI, MTSO, EVC, act, bdw, uni2, mtso2, A_END_ADDRESS, uni1full, uni2full, ckt_full
    )
b,
data_ext.asr_sali sali
where b.document_number = sali.document_number (+)
) 
where substr(ckt_full,4,1) = 'V'
)
gp,
     circuit c30,
     network_location nl30,                                
     network_location nl31,                                
     conn_ca_value ccv31,                                
     conn_ca_value ccv34,
     circuit c40,
     network_location nl40,                                
     network_location nl41,                                
     conn_ca_value ccv41,                                
     conn_ca_value ccv44                                   
where substr(gp.uni1full,1,14) = substr(c30.exchange_carrier_circuit_id,1,14)
and c30.LOCATION_ID = NL30.LOCATION_ID (+)                                --change to location_id for the A end node.
AND c30.LOCATION_ID_2 = NL31.LOCATION_ID (+)                                
and c30.circuit_design_id = ccv31.CIRCUIT_DESIGN_ID (+)                                
and c30.circuit_design_id = ccv34.CIRCUIT_DESIGN_ID (+)                                
and ccv31.CA_VALUE_LABEL (+) = 'RAD Management IP' --and ccv1.current_row_ind (+) = 'Y'                                
and ccv34.CA_VALUE_LABEL (+) = 'Bit Rate' --and ccv4.current_row_ind (+) = 'Y'         
and substr(gp.mtso_full,1,14) = substr(c40.exchange_carrier_circuit_id,1,14)
and c40.LOCATION_ID = NL40.LOCATION_ID (+)                                --change to location_id for the A end node.
AND c40.LOCATION_ID_2 = NL41.LOCATION_ID (+)                                
and c40.circuit_design_id = ccv41.CIRCUIT_DESIGN_ID (+)                                
and c40.circuit_design_id = ccv44.CIRCUIT_DESIGN_ID (+)                                
and ccv41.CA_VALUE_LABEL (+) = 'RAD Management IP' --and ccv1.current_row_ind (+) = 'Y'                                 
and ccv44.CA_VALUE_LABEL (+) = 'Bit Rate' --and ccv4.current_row_ind (+) = 'Y'       
and substr(evc_full,4,1) = 'V'
group by ban, acna, customer, state, lata, pnum, address, year, dd_comp, city, uni, mtso, evc,  
        act, bdw, los, uni_spec, mtso_spec, A_END_ADDRESS, uni1full, mtso_full, evc_full, gp.type,
       c30.EXCHANGE_CARRIER_CIRCUIT_ID, c30.circuit_design_id, c30.status, 
       nl30.clli_code, nl30.location_name, nl30.h_coordinate, nl30.v_coordinate, 
       nl31.clli_code, nl31.location_name, nl31.h_coordinate, nl31.v_coordinate,
       c40.EXCHANGE_CARRIER_CIRCUIT_ID, c40.circuit_design_id, c40.status, 
       nl40.clli_code, nl40.location_name, nl40.h_coordinate, nl40.v_coordinate, 
       nl41.clli_code, nl41.location_name, nl41.h_coordinate, nl41.v_coordinate
order by 14,19;
