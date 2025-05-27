


select *
from serv_req
where first_ecckt_id like '31/VLXP/718514%'


select * from ASAP.CONN_CA_VALUE where CA_VALUE_LABEL like 'RUID%' 
and circuit_design_id in (
'4918310',
'4458280',
'4458449',
'4891056',
'4895157',
'4893396',
'4895457',
'4589370',
'4589366',
'4587662',
'4587663',
'4674971',
'4675019',
'5220541',
'5153490',
'5153493',
'5163290',
'5163291',
'4999088',
'3784361',
'3785643',
'3785557',
'3785559',
'3784366',
'3783099')


select * from circuit
where substr(exchange_carrier_circuit_id,1,14) in (
'50/VLGS/457043',
'50/VLGS/457047')   
