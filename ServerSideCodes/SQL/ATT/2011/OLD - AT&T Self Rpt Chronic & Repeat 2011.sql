select region, state, ID||sc prod, ckt_id, disp, report_date, TOTAL_DUR_INT_TIME
from (
select state,
       case when state in ('IL','IN','MI','OH','WI') then 'MW'
	        when state in ('NC','SC') then 'SE'
			when state in ('AZ','CA','ID','WA','OR') then 'WC'
			else state end region,
	   case when acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   			 	  	  'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC',
						  'BAK','BAO','BCU','BFL','BGH','BPN','BSM','CBL','CCB','CDA','CEO',
						  'CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
						  'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA',
						  'FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','IMP',
						  'IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
						  'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR',
						  'MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW',
						  'OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC',
						  'SBG','SBM','SBN','SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM',
						  'SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD','VRA',
						  'WBT','WGL','WLG','WLZ','WVO','WWC') then 'MOB'
			 when acna in ('TPM','ACC','ANF','ETL','IPS') then 'TPM'	
				else acna end ID,	
		case when service_code = 'HC' then 'DS1'
	   		when service_code = 'HF' then 'DS3'
			when service_code like 'K%' then 'Ethernet'
			when service_code like 'V%' then 'Ethernet'
			when service_code like 'L%' then 'DS0'
			when service_code like 'X%' then 'DS0'
			when service_code = 'OB' then 'OC3'
			when service_code = 'OD' then 'OC12'
			when service_code = 'OF' then 'OC48'
			when service_code = 'OG' then 'OC192'
			when (service_code = 'M8' and carrier_type = 'T1') then 'DS1'
		    when (service_code = 'M8' and carrier_type = 'T3') then 'DS3'
			when ckt_id like '%T1%' then 'DS1'
			when ckt_id like '%T3%' then 'DS3'
		else service_code end sc,
	   ckt_id, 
	   case when dspsn in ('4','6','7','9','10','11','12','15') then 'F'
	    else 'NF' end disp,
	   report_date, TOTAL_DUR_INT_TIME
from OSSAMS_MART.TB_DM_OSSAMS_REPAIR_FACT
where acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC',
'BAK','BAO','BCU','BFL','BGH','BPN','BSM','CBL','CCB','CDA','CEO',
'CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','ETP','EST','ETX','FLA',
'FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','IMP',
'IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR',
'MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW',
'OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC',
'SBG','SBM','SBN','SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM',
'SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD','VRA',
'WBT','WGL','WLG','WLZ','WVO','WWC','ATX','TPM')
and TO_CHAR(AGE_DATE, 'YYYYMMDD') in ('20110701','20110801') --Last data month and current data month 
and TO_CHAR(REPORT_DATE, 'YYYYMMDD') >= '20110701'    ---1st day of Last data month    
and circuit_format in ('S','C')
and REPORT_SOURCE = '3'
and REPORT_TYPE = '1'
and INVALID_IND not in ('I')
and substr(MODIFIER,2,1) <> 'U'
and state in ('AZ','CA','ID','IL','IN','MI','NC','NV','OH','OR','SC','WA','WI')
and DSPSN  in ('4','6','7','9','10','11','12','13','15')
)
order by ckt_id, report_date