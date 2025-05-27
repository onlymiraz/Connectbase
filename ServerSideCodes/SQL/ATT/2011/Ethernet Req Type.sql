select ord, req_type, req_type_2, sei 
from naccprod.asr_dim
where version = 0
and ord in (
'CGC1032386284',
'CGC1091386037',
'CGC1019386250',
'CGC1006486291',
'CGC1007386236',
'CGC1089386135',
'CGC1019386249',
'CGC1038386224',
'CGC0355386160',
'CGC1053486184'
)
order by ord