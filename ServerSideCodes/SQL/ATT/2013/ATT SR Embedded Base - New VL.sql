select distinct ckt, icsc, 
       case when state2 is not null and state2 <> 'EF' then state2
            when icsc = 'SN01' then 'CT'
            when icsc = 'RT01' then 'NY'
            when state3 is not null then state3
            else state1 end state, 
       svc_cd,  
       case when clec_id in ('ATX','TPM','AAV','SBB','SBZ','SUV') then ' ATX' else 'MOB' end company,
	   case when substr(svc_cd,1,2) in ('HC','HX','T1') then 'DS1'
	        when substr(svc_cd,1,2) in ('HF','T3') then 'DS3'
            when substr(svc_cd,1,2) in ('SX') then 'Ethernet-NNI'
			when substr(svc_cd,1,1) in ('K') then 'Ethernet-UNI'
			when substr(svc_cd,1,1) in ('V') then 'Ethernet-EVC'
			when substr(svc_cd,1,1) in ('X','L') then 'DS0'
			when svc_cd in ('OB','OC3','OC03','OC03P','OC03N') then 'OC3'
			when svc_cd in ('OD','OC12','OC12N','OC12P','OC12C','O12P') then 'OC12'
			when svc_cd in ('OF','OC48','OC48P') then 'OC48'
			when svc_cd in ('OG','OC192') then 'OC192'
			else null end product			
from (
select ckt, icsc, rate, type,
       case when acna1 = 'BNK' and ccna2 is not null then ccna2
	        when acna1 is not null then acna2
			when acna2 = 'BNK' and ccna1 is not null then ccna1
			when acna2 is not null then acna1
	        else ccna1 end clec_id,
	   state1, state2, state3, ocn, svc_cd, status, juris, ordnum, lastmod		
from (
select exchange_carrier_circuit_id ckt,
       max(ec_company_code) keep (dense_rank first order by d.last_modified_date) icsc, 
       max(rate_code) keep (dense_rank last order by c.last_modified_date) rate, 
	   max(c.type) keep (dense_rank last order by c.last_modified_date) type, 
	   max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,
	   max(d.acna) keep (dense_rank first order by d.acna) acna2, 
	   max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,  
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) state1,
       max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl2.last_modified_date) state2,
       null state3, 
	   max(nl1.operating_company_number) keep (dense_rank last order by nl1.last_modified_date) ocn,
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
	   max(c.jurisdiction_code) keep (dense_rank last order by c.last_modified_date) juris,
	   max(substr(d.order_nbr,1,3)) keep (dense_rank last order by d.last_modified_date) ordnum,
	   max(d.last_modified_userid)  keep (dense_rank last order by d.last_modified_date) lastmod
from circuit c, design_layout_report d, network_location nl1, network_location nl2
where c.exchange_carrier_circuit_id = d.ecckt
and c.LOCATION_ID = NL1.LOCATION_ID(+)
and c.LOCATION_ID_2 = NL2.LOCATION_ID(+)
and c.type <> 'T'
and (substr(service_type_code,1,2) in ('HC','HF','HX','VL','KE','KF','KG','KQ','KR','T1','T3','SX')
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
--
UNION ALL
--
select exchange_carrier_circuit_id ckt,
     max(asr.access_provider_serv_ctr_code) keep (dense_rank first order by asr.last_modified_date) icsc, 
     max(c.rate_code) keep (dense_rank last order by c.last_modified_date) rate, 
	   max(c.type) keep (dense_rank last order by c.last_modified_date) type, 
	   max(sr.acna) keep (dense_rank last order by sr.last_modified_date) acna1, 
	   max(sr.ccna) keep (dense_rank last order by sr.last_modified_date) ccna1,
	   max(sr.acna) keep (dense_rank first order by sr.acna) acna2, 
	   max(sr.ccna) keep (dense_rank first order by sr.ccna) ccna2,  
	   max(substr(nl1.clli_code,5,2)) keep (dense_rank last order by nl1.last_modified_date) state1,
       max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl2.last_modified_date) state2,
       max(substr(npa.exchange_area_clli,5,2)) keep (dense_rank last order by npa.last_modified_date) state3,
	   max(nl1.operating_company_number) keep (dense_rank last order by nl1.last_modified_date) ocn,
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
	   max(c.jurisdiction_code) keep (dense_rank last order by c.last_modified_date) juris,
	   max(substr(d.order_nbr,1,3)) keep (dense_rank last order by d.last_modified_date) ordnum,
	   max(d.last_modified_userid)  keep (dense_rank last order by d.last_modified_date) lastmod
from circuit c, design d, network_location nl1, network_location nl2, ASAP.design_ord_summ dos ,asap.serv_req sr, asap.access_service_request asr, npa_nxx npa
where c.exchange_carrier_circuit_id = d.ckt_ident
and c.LOCATION_ID = NL1.LOCATION_ID(+)
and c.LOCATION_ID_2 = NL2.LOCATION_ID(+)
and asr.npa = npa.npa (+)
and asr.nxx = npa.nxx (+)
and c.type <> 'T'
and (substr(c.service_type_code,1,2) in ('HC','HF','HX','VL','KE','KF','KG','KQ','KR','T1','T3','SX')
    or substr(c.service_type_code,1,1) in ('X','L','O'))
and c.service_type_code <> 'OS'
and sr.ccna in ('ATX','TPM','AAV','SBB','SBZ','SUV',
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
and d.design_ord_sum_id =  dos.design_ord_sum_id
and dos.document_number =  sr.document_number
and dos.document_number = asr.document_number
group by c.exchange_carrier_circuit_id
))
where substr(ckt,7,1) <> 'U'
and status = '6'
--and (icsc not in ('RT01') or icsc is null)
order by 1;





--To see if any of the VLXP circuits have been Disconnected    
select * 
from serv_req sr,
     task t
where sr.document_number = t.document_number
and t.task_type = 'DD'
and first_ecckt_id like '%/VLXP%/GTE%'
and acna in ('AWL')
and activity_ind = 'D'
and to_char(actual_completion_date,'yyyymm') >= '201412'   
and (supplement_type <> 1 or supplement_type is null); 
