SELECT --AL2.CIRCUIT_DESIGN_ID, 
       AL2.EXCHANGE_CARRIER_CIRCUIT_ID, 
	   AL2.LOCATION_ID, 
	   max(AL1.OPERATING_COMPANY_NUMBER) keep (dense_rank last order by al1.last_modified_date), 
	   Max (AL1.LAST_MODIFIED_DATE), 
	   SUBSTR ( AL1.EXCHANGE_AREA_CLLI, 5, 2 ), 
	   AL1.EXCHANGE_AREA_CLLI, 
	   max(AL3.ccna) keep (dense_rank last order by al3.last_modified_date)
FROM CASDW.NETWORK_LOCATION AL1, CASDW.CIRCUIT AL2, casdw.design_layout_report al3
WHERE AL2.LOCATION_ID=AL1.LOCATION_ID
and AL2.EXCHANGE_CARRIER_CIRCUIT_ID = AL3.ecckt(+)
AND (SUBSTR ( AL1.EXCHANGE_AREA_CLLI, 5, 2 )='WV') 
and AL1.OPERATING_COMPANY_NUMBER not in ('9214','0270')
GROUP BY --AL2.CIRCUIT_DESIGN_ID, 
AL2.EXCHANGE_CARRIER_CIRCUIT_ID, AL2.LOCATION_ID, 
         --AL1.OPERATING_COMPANY_NUMBER, 
		 SUBSTR ( AL1.EXCHANGE_AREA_CLLI, 5, 2 ), AL1.EXCHANGE_AREA_CLLI
order by 1

select * from casdw.access_service_request
where ic_circuit_reference like '50%HCFA%427597%'


select * from casdw.circuit
where exchange_carrier_circuit_id like '50/HCGS/079840%'

select * from casdw.design_layout_report
where ecckt like '50/HCGS/079840%'

select * from casdw.network_location
where location_id = '12134'