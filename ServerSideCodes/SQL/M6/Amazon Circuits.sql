Select distinct
regexp_replace(amzn.exchange_carrier_circuit_id,'[^a-zA-Z0-9'']','') as clean_circuit_id
, amzn.exchange_carrier_circuit_id
, case when src.circuit_activity_ind = 'N' then tsk.actual_completion_date else null end as dd_comp_n
, case when sr.ccna is not null then sr.ccna
       when sr.acna is not null then sr.acna else null end as ccna_acna
, case when sr.ccna is not null then sr.ccna_name
       when sr.acna is not null then sr.acna_name else null end as ccna_acna_name
, CASE WHEN amzn.nc IN ('SB', 'SD', 'SH', 'SI', 'SJ', 'SN', 'SP', 'SV', 'SE', 'SF') THEN 'SWITCHED'
     WHEN SUBSTR(amzn.exchange_carrier_circuit_id,4,2) IN ('OB','OD','OF','OG','OZ','JI','JJ','JK','MK','XS') THEN 'OCN'
     WHEN SUBSTR(amzn.exchange_carrier_circuit_id,7,2) IN ('OC') THEN 'OCN'
     WHEN SUBSTR(amzn.nc,1,2) IN ('OB','OD','OF','OG','OZ','JI','JJ','JK','XS') THEN 'OCN'
     WHEN (amzn.nc = 'HC' OR SUBSTR(amzn.exchange_carrier_circuit_id,4,2) IN ('HC','YI','DH','QG','IP','UH')) THEN 'DS1'
     WHEN (amzn.nc = 'HF' OR SUBSTR(amzn.exchange_carrier_circuit_id,4,2) IN ('HF')) THEN 'DS3'
     WHEN SUBSTR(amzn.exchange_carrier_circuit_id,7,2) = 'T1' THEN 'DS1'
     WHEN SUBSTR(amzn.exchange_carrier_circuit_id,7,2) = 'T3' THEN 'DS3'
     WHEN SUBSTR(amzn.exchange_carrier_circuit_id,4,2) IN ('LB','LC','LD','LE','LF','LG','LH','LJ','LK','LN','LP','LQ','LR', 
       'LX','MQ','NQ','NT','NU','NV','NW','NY','PE','PF','PJ','PK','PQ','SE','SF','UC','UD', 
       'UG','US','XA','XB','XC','XD','XE','XG','XH','XR','YH','IP','FZ') THEN 'DS0'
     WHEN SUBSTR(amzn.nc,1,2) IN ('LB','LC','LD','LE','LF','LG','LH','LJ','LK','LN','LP','LQ','LR', 
        'LX','MQ','NQ','NT','NU','NV','NW','NY','PE','PF','PJ','PK','PQ','SE','SF','UC','UD', 
        'UG','US','XA','XB','XC','XD','XE','XG','XH','XR','YH','IP','FZ') THEN 'DS0'
     WHEN (SUBSTR(amzn.nc,1,2) IN ('KD','KE','KF','KG','KP','KQ','KR','KS') 
       or SUBSTR(amzn.svc_type,1,2) IN ('KD','KE','KF','KG','KP','KQ','KR','KS')
       OR SUBSTR(amzn.exchange_carrier_circuit_id,4,2) IN ('KD','KE','KF','KG','KP','KQ','KR','KS','L2','L1')) THEN 'ETHERNET-UNI'
     WHEN (SUBSTR(amzn.nc,1,2) = 'VL' or SUBSTR(amzn.svc_type,1,2) = 'VL' 
       OR SUBSTR(amzn.exchange_carrier_circuit_id,4,2) = 'VL') THEN 'ETHERNET-EVC'
     ELSE amzn.rate_cd END PRODUCT
, amzn.first_docnum
--, min(src.document_number) keep (dense_rank first order by src.last_modified_date) as document_number
--, src.document_number
, src.circuit_activity_ind as act_c
--, max(sr.pon) keep (dense_rank last order by sr.last_modified_date) as pon
, sr.pon
, nl.location_name as loc_name1
, adr.addr_ln1 as street_1
, adr.addr_ln3 as city_st_1
, nl2.location_name as loc_name2
, adr2.addr_ln1 as street_2
, adr2.addr_ln3 as city_st_2
, sali.euname   
--, amzn.circuit_design_id
--, amzn.cir_loc_id_1
--, amzn.cir_loc_id_2
--, amzn.nc
--, amzn.svc_type
--, st.code_short_description as service_description
--, amzn.rate_cd
--, amzn.status
--, substr(nl.clli_code,5,2) as state
from 
--serv_req sr, service_request_circuit src, data_ext.asr_sali sali, network_location nl, network_location nl2, net_loc_addr nla, net_loc_addr nla2
--  , address adr, address adr2, task tsk,
--
-- FIND THOSE WITH LOCATION NAMES THAT INCLUDE AMAZON NAMES
(
select distinct
cir.exchange_carrier_circuit_id
, cir.circuit_design_id
, cir.location_id as cir_loc_id_1
, cir.location_id_2 as cir_loc_id_2
, cir.network_channel_service_code as NC
, cir.service_type_code as svc_type
, cir.type
, cir.rate_code as rate_cd
, cir.status
, min(src.document_number) keep (dense_rank first order by src.completion_date) as first_docnum
from circuit cir
 left outer join service_request_circuit src on cir.circuit_design_id = src.circuit_design_id
  inner join (select distinct location_id, location_name from network_location 
    where (location_name like ('%AMAZON%') or location_name like ('%GOLDEN STATE%') or location_name like ('%VADATA%'))
    and location_name not like ('%GOLDEN STATE FOODS%') 
    and location_name not like ('%GOLDEN STATE DOORS%')
    and location_name not like ('%GOLDEN STATE WATER%')
    ) amzn1
    on (amzn1.location_id = cir.location_id or amzn1.location_id = cir.location_id_2)
where cir.status = '6'
group by cir.exchange_carrier_circuit_id, cir.circuit_design_id, cir.location_id, cir.location_id_2, cir.network_channel_service_code
  , cir.service_type_code, cir.rate_code, cir.status, cir.type
--
union
-- FIND THOSE WITH EUNAME THAT INCLUDE AMAZON NAMES
select distinct
cir.exchange_carrier_circuit_id
, cir.circuit_design_id
, cir.location_id as cir_loc_id_1
, cir.location_id_2 as cir_loc_id_2
, cir.network_channel_service_code as NC
, cir.service_type_code as svc_type
, cir.type
, cir.rate_code as rate_cd
, cir.status
, min(src.document_number) keep (dense_rank first order by src.completion_date) as first_docnum
from circuit cir
 left outer join service_request_circuit src on cir.circuit_design_id = src.circuit_design_id
  inner join (select distinct data_ext.asr_sali.document_number, euname, first_ecckt_id from data_ext.asr_sali, serv_req
    where serv_req.document_number = data_ext.asr_sali.document_number
    and (euname like ('%AMAZON%') or euname like ('%GOLDEN STATE%') or euname like ('%VADATA%'))
    and euname not like ('%GOLDEN STATE FOODS%')
    and euname not like ('%GOLDEN STATE DOORS%')
    and euname not like ('%GOLDEN STATE BANK%')
    and euname not like ('%GOLDEN STATE WATER%')
    and euname not like ('%AMAZON HOSE%')
    ) amzn2
    on amzn2.first_ecckt_id = cir.exchange_carrier_circuit_id
where cir.status = '6'
group by cir.exchange_carrier_circuit_id, cir.circuit_design_id, cir.location_id, cir.location_id_2, cir.network_channel_service_code
  , cir.service_type_code, cir.rate_code, cir.status, cir.type
--
union
-- FIND OTHER KNOWN CIRCUITS FOR AMAZON THAT MAY NOT CARRY THE AMAZON NAME IN THE LOCATION IDs
select distinct
cir.exchange_carrier_circuit_id
, cir.circuit_design_id
, cir.location_id as cir_loc_id_1
, cir.location_id_2 as cir_loc_id_2
, cir.network_channel_service_code as NC
, cir.service_type_code as svc_type
, cir.type
, cir.rate_code as rate_cd
, cir.status
, min(src.document_number) keep (dense_rank first order by src.completion_date) as first_docnum
from circuit cir
 left outer join service_request_circuit src on cir.circuit_design_id = src.circuit_design_id
where cir.exchange_carrier_circuit_id in ('50/KFGS/578926/   /FVNC/   ')--, ' ./KRGN/825896/   /ATI /   ', ' ./KQGN/996564/   /ATI /   ')
and cir.status = '6'
group by cir.exchange_carrier_circuit_id, cir.circuit_design_id, cir.location_id, cir.location_id_2, cir.network_channel_service_code
  , cir.service_type_code, cir.rate_code, cir.status, cir.type
) amzn
left outer join serv_req sr on amzn.first_docnum = sr.document_number
left outer join service_request_circuit src on amzn.first_docnum = src.document_number
left outer join data_ext.asr_sali sali on amzn.first_docnum = sali.document_number
left outer join task tsk on amzn.first_docnum = tsk.document_number
left outer join network_location nl on amzn.cir_loc_id_1 = nl.location_id
left outer join network_location nl2 on amzn.cir_loc_id_2 = nl2.location_id
left outer join net_loc_addr nla on nl.location_id = nla.location_id
left outer join net_loc_addr nla2 on nl2.location_id = nla2.location_id
left outer join address adr on nla.address_id = adr.address_id
left outer join address adr2 on nla2.address_id = adr2.address_id
left outer join service_type st on (amzn.svc_type = st.service_type_code and (amzn.type = st.circuit_type  
      or (st.service_type_code in ('KD','KE','KF','KG','KP','KQ','KR','KS') and st.circuit_type is not null)
      -- NEEDED CARVE OUT IN PRIOR LINE OF CODE FOR CIRCUIT TYPE MISMATCHES ON K CIRCUITS
      or st.service_type_code in (select distinct service_type_code from service_type where circuit_type is null
        and service_type_code not in (select distinct service_type_code from service_type where circuit_type is not null))))
        -- NEED CARVE OUT FOR SERVICE CODES LACKING A CIRCUIT TYPE IN SERVICE TYPE TABLE(PRIOR TWO LINES OF CODE)
where (nla.active_ind = 'Y' or nla.active_ind is null)
and (nla2.active_ind = 'Y' or nla2.active_ind is null)
and (tsk.task_type = 'DD' or task_type is null)
and (SUBSTR(amzn.nc,1,2) IN ('KD','KE','KF','KG','KP','KQ','KR','KS') 
       or SUBSTR(amzn.svc_type,1,2) IN ('KD','KE','KF','KG','KP','KQ','KR','KS')
       or SUBSTR(amzn.exchange_carrier_circuit_id,4,2) IN ('KD','KE','KF','KG','KP','KQ','KR','KS','L2','L1'))
/*group by amzn.exchange_carrier_circuit_id, amzn.circuit_design_id, amzn.cir_loc_id_1, amzn.cir_loc_id_2, amzn.nc, amzn.svc_type
  , amzn.rate_cd, amzn.status, sr.pon, src.circuit_activity_ind, tsk.actual_completion_date, nl.location_name, adr.addr_ln1
  , adr.addr_ln3, nl2.location_name, adr2.addr_ln1, adr2.addr_ln3, sali.euname, sr.ccna, sr.ccna_name, sr.acna, sr.acna_name
*/
order by 3