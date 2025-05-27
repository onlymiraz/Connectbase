select c.exchange_carrier_circuit_id, c.location_id, c.location_id_2, a.*, z.*
from circuit c,
     net_loc_addr nla,
     net_loc_addr nlz,
     address a,
     address z
where c.location_id = nla.location_id and nla.active_ind = 'Y'
  and c.location_id_2 = nlz.location_id and nlz.active_ind = 'Y'
  and nla.address_id = a.address_id
  and nlz.address_id = z.address_id
  and c.exchange_carrier_circuit_id like '61/KXGS/000025%'