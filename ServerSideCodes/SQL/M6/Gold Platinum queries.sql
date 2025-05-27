select rel_uni_ident, eum.document_number, sr.first_ecckt_id
from evc_uni_map eum, serv_req sr
where eum.document_number = sr.document_number 
and (rel_uni_ident,1,14) in ('45/KFGS/576748'
)
;  




SELECT SR.PON,
  SR.DOCUMENT_NUMBER,   
  MAX(SR.ACTIVITY_IND) keep (dense_rank last order by sr.last_modified_date) ACT_IND,
  MAX(SR.SUPPLEMENT_TYPE) keep (dense_rank last order by sr.last_modified_date) SUPP_TYPE,
  MAX(SR.FIRST_ECCKT_ID) keep (dense_rank last order by sr.last_modified_date) CKT,
  max(asr.ic_circuit_reference) keep (dense_rank last order by asr.last_modified_date) ckt2,
  max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) D_REC, 
  max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
  max(AUD.crdd) keep (dense_rank last order by aud.last_modified_date) DDD,
  MAX(AUD.ACCEPTANCE_DATE) keep (dense_rank last order by aud.last_modified_date) ACCEPT_DT,
  MAX(TRUNC(TSK.ACTUAL_COMPLETION_DATE)) keep (dense_rank last order by tsk.last_modified_date) DD_COMP,
  MAX(ASR.ACCESS_PROVIDER_SERV_CTR_CODE) keep (dense_rank last order by asr.last_modified_date) ICSC,
  MAX(REPLACE(SR.PROJECT_IDENTIFICATION,' ')) keep (dense_rank last order by sr.last_modified_date) PROJ,
  MAX(SR.ACNA) keep (dense_rank last order by sr.last_modified_date) ACNA,
  max(asr.ckr) keep (dense_rank last order by asr.last_modified_date) ckr,
  max(asr.connecting_facility_assignment) keep (dense_rank last order by asr.last_modified_date) CFA,
  MAX(CIR.RATE_CODE) keep (dense_rank last order by cir.last_modified_date) RATE_CODE,
  MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) keep (dense_rank last order by asr.last_modified_date) NC, 
  max(CIR.EXCHANGE_CARRIER_CIRCUIT_ID) keep (dense_rank last order by cir.last_modified_date) CIRCKT,
  MAX(ASR.promotion_nbr) keep (dense_rank last order by asr.last_modified_date) pnum,
  max(asr.service_and_product_enhanc_cod) keep (dense_rank last order by asr.last_modified_date) SPEC
  --
FROM SERV_REQ SR, 
   ACCESS_SERVICE_REQUEST ASR, 
     NETWORK_LOCATION NL1,
     NETWORK_LOCATION NL2,
     CIRCUIT CIR,
     DESIGN_LAYOUT_REPORT DLR, 
     TASK TSK,
     ASR_USER_DATA AUD
--
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = DLR.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)
AND DLR.CIRCUIT_DESIGN_ID = CIR.CIRCUIT_DESIGN_ID (+)
AND CIR.LOCATION_ID = NL1.LOCATION_ID (+)
AND CIR.LOCATION_ID_2 = NL2.LOCATION_ID (+)
AND SR.TYPE_OF_SR in ('ASR')
AND TSK.TASK_TYPE = 'DD'
and sr.document_number in (
'2390417')
--
GROUP BY SR.DOCUMENT_NUMBER,
  SR.PON;
  
  
  
  
select distinct ban, acna, state, lata, usid, ckr, address, to_char(dd_comp,'YYYY') year, build_year, program, sche2e, acte2e, schread,
       dd_comp, unihold, evchold, mtsohold, city, 
       uni, evc, mtso, act, bdw, uni2, mtso2, 
       case when mtsosize = 28 then mtso2 else mtso end mtso1,
       A_END_NODE, A_NODE_TYPE, A_END_NODE_IP, A_END_ADDRESS, null VLAN_ID,
       Z_END_NODE, Z_NODE_TYPE, Z_END_NODE_IP, Z_END_ADDRESS,
       case when icsc in ('GT10','GT11') then 'CTF' else 'Legacy' end type
from (        
select b.ban, b.acna, substr(sali.state,1,2) state, 
       b.lata, null usid, b.ICSC,
       case when substr(b.evcckr,1,1) = '1' then evcckr
       else b.ckr end ckr,
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
       --b.ckt UNI1,
       b.UNI UNI,
       b.MTSO,
       b.EVC, 
       b.act, b.bdw, uni2, mtso2,
       length(b.mtso) mtsosize,
       A_END_NODE, A_NODE_TYPE, A_END_NODE_IP, A_END_ADDRESS,
       Z_END_NODE, Z_NODE_TYPE, Z_END_NODE_IP, Z_END_ADDRESS
from (
    select sr2.document_number, co2.lata_number lata, ICSC,
       ban, a.acna, evcckr, dd_comp, UNI, MTSO,
       EVC, act, bdw, asr2.ckr, uni2, mtso2,
       A_END_NODE, A_NODE_TYPE, A_END_NODE_IP, A_END_ADDRESS,
       Z_END_NODE, Z_NODE_TYPE, Z_END_NODE_IP, Z_END_ADDRESS
    from (
       select ban, acna, lata, evcckr, dd_comp, ICSC,
           case when substr(uni1,4,2) <> 'KG' then uni1
           else uni2 end UNI,
           case when substr(uni1,4,2) = 'KG' then uni1
           else uni2 end MTSO,
           ckt EVC, document_number, act, bdw,
           case when substr(uni1,4,2) <> 'KG' then evcmp1
           else evcmp2 end UNI2,
           case when substr(uni1,4,2) = 'KG' then evcmp1
           else evcmp2 end MTSO2,
        A_END_NODE, A_NODE_TYPE, A_END_NODE_IP, A_END_ADDRESS,
        Z_END_NODE, Z_NODE_TYPE, Z_END_NODE_IP, Z_END_ADDRESS   
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
            max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,
            max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,
            co.lata_number lata,
            evc.bdw,
            evc.ruid uni1,
            evc2.ruid uni2,
            eum.evc_meet_point_id evcmp1,
            eum2.evc_meet_point_id evcmp2,
            evc.evc_evcckr evcckr,
            nl2.exchange_area_clli,
            nlud2.ip_address as A_END_NODE_IP,
            nlud2.equipment_type as A_NODE_TYPE,
            nl2.clli_code as A_END_NODE,
            replace(addr2.addr_ln1,'MSAG ')||', '||addr2.addr_ln3 as A_END_ADDRESS,
            nlud3.ip_address as Z_END_NODE_IP,
            nlud3.equipment_type as Z_NODE_TYPE,
            nl3.clli_code as Z_END_NODE,
            replace(addr3.addr_ln1,'MSAG ')||', '||addr3.addr_ln3 as Z_END_ADDRESS
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
             network_location nl3,
             network_location_user_data nlud2, 
             network_location_user_data nlud3,
             net_loc_addr nla2, 
             net_loc_addr nla3, 
             address addr2,
             address addr3
        where sr.document_number = asr.document_number
        and sr.document_number = aud.document_number(+)
        and sr.first_ecckt_id = c.exchange_carrier_circuit_id
        and c.location_id = nl2.location_id(+)
        and sr.document_number = t.document_number
        and nl2.exchange_area_clli = co.exchange_area_clli (+)
        and sr.document_number = evc.document_number (+)
        and sr.document_number = evc2.document_number (+)
        and sr.document_number = eum.document_number (+)
        and sr.document_number = eum2.document_number (+)
        and c.location_id = nlud2.location_id (+)
        and c.location_id_2 = nlud3.location_id (+)
        and c.location_id_2 = nl3.location_id (+)
        and c.location_id = nla2.location_id (+)
        and c.location_id_2 = nla3.location_id (+)
        and nla2.address_id = addr2.address_id (+)
        and nla3.address_id = addr3.address_id (+)
        --and to_char(t.actual_completion_date,'yyyymmdd') >= ('20160909')
        --and sr.document_number = '2389234'   
        and asr.request_type in ('S','E')
        and asr.activity_indicator in ('N')
        and asr.order_type = 'ASR' 
        and t.task_type = 'DD'
        and sr.document_number in (
        '2390417')
        and evc.uref = '01'
        and evc2.uref = '02'
        and eum.uni_ref_nbr = '01'
        and eum2.uni_ref_nbr = '02'
        group by aud.document_number, asr.request_type, t.actual_completion_date, co.lata_number, evc.evc_evcckr, evc.ruid, evc2.ruid, evc.bdw, nl2.exchange_area_clli,
        eum.evc_meet_point_id, eum2.evc_meet_point_id, nlud2.ip_address, nlud2.equipment_type, nl2.clli_code, addr2.addr_ln1, addr2.addr_ln3,
        nlud3.ip_address, nlud3.equipment_type, nl3.clli_code, addr3.addr_ln1, addr3.addr_ln3
        )
       where (supp <> 1 or supp is null)
       and (substr(nc,1,1) in ('V') 
       or substr(ckt,4,1) in ('V')
	   or substr(ckt,1,6) = 'R2LMMQ')
       ) a,
         serv_req sr2,
         access_service_request asr2, 
         circuit c2,
         network_location nl4, 
         central_office_exchange_area co2
    where substr(a.uni,1,14) = substr(sr2.first_ecckt_id(+),1,14)
    and sr2.document_number = asr2.document_number (+)
    and sr2.first_ecckt_id = c2.exchange_carrier_circuit_id (+)
    and nl4.exchange_area_clli = co2.exchange_area_clli (+)
    and c2.location_id = nl4.location_id (+)
    and sr2.activity_ind (+) = 'N'
    )
b,
data_ext.asr_sali sali
where b.document_number = sali.document_number (+)
)
order by 3,20;  