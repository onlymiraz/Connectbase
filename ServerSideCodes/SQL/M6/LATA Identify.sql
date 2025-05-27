select distinct c.EXCHANGE_CARRIER_CIRCUIT_ID, asr.document_number, asr.pon, asr.lata_number asr_lata, co1.lata_number cllia_lata, co2.lata_number clliz_lata
from circuit c,
     service_request_circuit src,
     access_service_request asr,
     network_location nl1,
     CENTRAL_OFFICE_EXCHANGE_AREA CO1,
     network_location nl2,
     CENTRAL_OFFICE_EXCHANGE_AREA CO2
where c.circuit_design_id = src.circuit_design_id
and src.document_number = asr.document_number
and c.location_id = nl1.location_id (+)
and c.location_id_2 = nl2.location_id (+)
and nl1.exchange_area_clli = co1.exchange_area_clli (+)
and nl2.exchange_area_clli = co2.exchange_area_clli (+)
and substr(c.EXCHANGE_CARRIER_CIRCUIT_ID,1,21) in (
'50/KRGN/119298/   /CZ',
'69/KEGS/701528/   /GT',
'30/KQGN/111240/   /FT')
order by 1,2
;




select * from central_office_exchange_area
where exchange_area_clli like 'CSVLTN%'
--where exchange_area_name like 'CROSSVILLE%'



select sr.document_number, sr.first_ecckt_id, c.exchange_carrier_circuit_id, nl1.clli_code cllia, co1.lata_number lataa,  sali.city
from serv_req sr,
     circuit c, 
	 network_location nl1,
	 central_office_exchange_area co1,
	 data_ext.asr_sali sali
where sr.first_ecckt_id = c.exchange_carrier_circuit_id (+)
and c.location_id = nl1.location_id (+)	
and nl1.exchange_area_clli = co1.exchange_area_clli (+)
and sr.document_number = sali.document_number (+)
and sr.acna = 'AWL'
and substr(sr.first_ecckt_id,4,1) = 'K'
and substr(sr.first_ecckt_id,5,1) <> 'G'
and sr.supplement_type <> '1'
--and sr.activity_ind = 'N'
and sr.order_compl_dt is not null 
and sr.order_number = '1017309' 



select c.*
from serv_req sr,
     circuit c
where substr(sr.first_ecckt_id,1,14) = substr(c.exchange_carrier_circuit_id,1,14) 
and sr.order_number = '1017309' 




select c.exchange_carrier_circuit_id, nl1.clli_code cllia, co1.lata_number lataa
from circuit c, 
	 network_location nl1,
	 central_office_exchange_area co1
where c.location_id = nl1.location_id (+)	
and nl1.exchange_area_clli = co1.exchange_area_clli (+)
and c.exchange_carrier_circuit_id in (
'61/KFGS/545743/   /FTNC/   ',
'61/KFGS/545743/   /FTNC/   ',
'61/KFGS/647006/   /FTNC/   ',
'61/KRGS/454243/   /FTNC/   ',
'63/KFGS/796496/   /FTNC/   ',
'63/KFGS/808216/   /FTNC/   ',
'63/KFGS/844278/   /FTNC/   ',
'63/KFGS/844362/   /FTNC/   ',
'63/KFGS/844793/   /FTNC/   ',
'63/KFGS/949991/   /FTNC/   ',
'63/KFGS/949992/   /FTNC/   ',
'63/KFGS/960664/   /FTNC/   ',
'63/KFGS/960701/   /FTNC/   ',
'63/KFGS/972212/   /FTNC/   ') 








select document_number, first_ecckt_id, project_identification 
from serv_req
where first_ecckt_id like 'G4/KFGS/921224%'

where document_number in (
'1418218',
'1463146',
'1464089',
'1465375',
'1477211',
'1493028',
'1500297',
'1448106',
'1510400',
'1519253',
'1519259')




select first_ecckt_id 
from serv_req
where first_ecckt_id like '13/KFGL/446622%'   
union all
select exchange_carrier_circuit_id 
from circuit
where exchange_carrier_circuit_id like '13/KFGL/446622%'


13/KFGL/446622/   /CZUC
13/KFGL/446622/   /CZUC