select ckt, icsc, state, svc_cd,  
       case when ccna in ('ATX','TPM','AAV','SBB','SBZ','SUV') then ' ATX' else 'MOB' end company,
	   case when substr(svc_cd,1,2) in ('HC','HX','T1') then 'DS1'
	        when substr(svc_cd,1,2) in ('HF','T3') then 'DS3'
			when substr(svc_cd,1,1) in ('K','V') then 'Ethernet'
			when substr(svc_cd,1,1) in ('X','L') then 'DS0'
			when svc_cd in ('OB','OC3','OC03','OC03P') then 'OC3'
			when svc_cd in ('OD','OC12','OC12N','OC12P') then 'OC12'
			when svc_cd in ('OF','OC48','OC48P') then 'OC48'
			when svc_cd in ('OG','OC192') then 'OC192'
			else null end product			
from (
select exchange_carrier_circuit_id ckt,
       max(ec_company_code) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(rate_code) keep (dense_rank last order by c.last_modified_date) rate, 
	   max(c.type) keep (dense_rank last order by c.last_modified_date) type, 
	   max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna,  
	   max(substr(clli_code,5,2)) keep (dense_rank last order by nl.last_modified_date) state, 
	   max(operating_company_number) keep (dense_rank last order by nl.last_modified_date) ocn,
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
	   max(c.jurisdiction_code) keep (dense_rank last order by c.last_modified_date) juris,
	   max(substr(d.order_nbr,1,3)) keep (dense_rank last order by d.last_modified_date) ordnum,
	   max(d.last_modified_userid)  keep (dense_rank last order by d.last_modified_date) lastmod
from circuit c, design_layout_report d, network_location nl
where c.exchange_carrier_circuit_id = d.ecckt
and c.LOCATION_ID = NL.LOCATION_ID(+)
and c.type <> 'T'
and (substr(service_type_code,1,2) in ('HC','HF','HX','VL','KE','KF','KG','KR','T1','T3')
    or substr(service_type_code,1,1) in ('X','L','O'))
and service_type_code <> 'OS'
and d.ccna in ('ATX','TPM','AAV','SBB','SBZ','SUV',
	           'AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   			  'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWS','AWL','AWN','AZE','BAC',
				  'BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','CBL','CCB','CDA','CEL',
				  'CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
				  'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','ETP','EST','ETX',
				  'FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','HWC',
				  'IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
				  'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ',
				  'MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV',
				  'OSU','PCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN','SCU',
				  'SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM',
				  'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO')
group by exchange_carrier_circuit_id
)
where substr(ckt,7,1) <> 'U'
and status = '6'
and (icsc not in ('RT01') or icsc is null)



