select *
from service_request_circuit src, circuit c, evc_lvl_serv els
where src.circuit_design_id = c.circuit_design_id
and src.document_number = els.document_number (+)
and c.exchange_carrier_circuit_id like '  /KQGN/707931%'
;

select * from serv_req
where document_number = '3356797'
--2529817
;

select distinct src.circuit_design_id, src.document_number, bandwidth, src.last_modified_date
from service_request_circuit src, evc_lvl_serv els
where src.document_number = els.document_number 
and src.circuit_design_id in (
'5800542')
order by 1,4
;


select distinct src.circuit_design_id,
       MAX(bandwidth) KEEP (DENSE_RANK LAST ORDER BY els.LAST_MODIFIED_DATE) bdw   
from service_request_circuit src,  evc_lvl_serv els
where src.document_number = els.document_number 
and src.circuit_design_id in (
'5808449',
'10068174'
)
group by src.circuit_design_id
;



        