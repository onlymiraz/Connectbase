select * --substr(exchange_carrier_circuit_id,1,14) ckt, exchange_carrier_circuit_id, circuit_design_id
from circuit
where exchange_carrier_circuit_id like 'R2LMMQ2217%'

where substr(exchange_carrier_circuit_id,1,14) in (
'H9/VLXP/564708')










select substr(exchange_carrier_circuit_id,1,14) ckt, exchange_carrier_circuit_id, circuit_design_id
from circuit
where substr(exchange_carrier_circuit_id,1,14) in (
'61/VLXP/459231')
and status = '6'
order by 1,2



SELECT DISTINCT  
         parent_circuit.exchange_carrier_circuit_id,   
         (select ccna from asap.design_layout_report where circuit_design_id = parent_circuit.circuit_design_id and ccna is not null and rownum = 1) "CCNA",
         asap.ns_con_rel.circuit_design_id_parent, 
         asap.circuit.circuit_design_id ,
         --asap.serv_item.serv_item_id,
         asap.circuit.exchange_carrier_circuit_id ,
         --asap.circuit.type ,
         asap.circuit.status
         --asap.circuit.service_type_category ,
         --asap.circuit.service_type_code ,
         --asap.circuit.rate_code ,
         --asap.ns_con_label_ckt.ns_con_label_id,
        --ns_component_parent.ns_comp_nm comp_nm_parent,
        --ns_component_parent.ns_comp_network_element_id element_id_parent,
        --ns_component_child.ns_comp_nm comp_nm_child,
        --ns_component_child.ns_comp_network_element_id element_id_child
    FROM asap.circuit ,
        asap.circuit parent_circuit ,
         asap.serv_item ,
         asap.ns_con_label_ckt,
        asap.ns_connection,
        asap.ns_component ns_component_parent,
        asap.ns_component ns_component_child,
        asap.ns_con_rel,
        asap.ns_con_rel ns_con_rel_b,
        asap.ns_con_rel_pending
   WHERE ( asap.circuit.circuit_design_id = asap.serv_item.circuit_design_id (+)) and   
         ( asap.circuit.circuit_design_id = asap.ns_con_label_ckt.circuit_design_id (+)) and
                                                ( asap.circuit.circuit_design_id = asap.ns_connection.circuit_design_id (+)) and
                                                ( asap.ns_connection.ns_comp_id_parent = ns_component_parent.ns_comp_id (+)) and
                                                ( asap.ns_connection.ns_comp_id_child = ns_component_child.ns_comp_id (+)) and
                                                ( asap.circuit.circuit_design_id = asap.ns_con_rel.circuit_design_id_child ) and
                                                ( asap.circuit.circuit_design_id = ns_con_rel_b.circuit_design_id_parent (+)) and
                                                ( asap.ns_con_rel.circuit_design_id_parent = asap.ns_con_rel_pending.circuit_design_id_rel_parent(+) and
                                                  asap.ns_con_rel.circuit_design_id_child = asap.ns_con_rel_pending.circuit_design_id_rel_child(+)) and
      ( asap.ns_con_rel.circuit_design_id_parent = parent_circuit.circuit_design_id ) and
      ( asap.ns_connection.circuit_design_id in 
('5142917'
)	  
	  )
order by 5




select * 
from circuit
where exchange_carrier_circuit_id like 'JP101%CRCYNV%'