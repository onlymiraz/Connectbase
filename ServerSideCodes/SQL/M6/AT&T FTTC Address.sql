select substr(exchange_carrier_circuit_id,1,14) ckt, exchange_carrier_circuit_id, street_nm, ga1.instance_value city, ga2.instance_value_abbrev st, postal_cd 
from CIRCUIT CIR,
     net_loc_addr nla,
     address a,
	 mv_ga_instance ga1,
	 mv_ga_instance ga2
where cir.location_id = nla.location_id
and nla.address_id = a.address_id
and ga_instance_id_city = ga1.ga_instance_id
and ga_instance_id_state_cd = ga2.ga_instance_id
and substr(exchange_carrier_circuit_id,1,14) in (
'36/VLXP/226215',
'86/VLXP/851271',
'86/VLXP/851277')


