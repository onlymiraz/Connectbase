--RFR for Baseline  

select state, ID, ckt_id, report_date
from (
select state,
	   case when acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   			 	  	  'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC',
						  'BAK','BAO','BCU','BFL','BGH','BPN','BSM','CBL','CCB','CDA','CEO',
						  'CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
						  'CSO','CSU','CSX','CTJ','CUO','CZB','DNC','ETP','EST','ETX','FLA',
						  'FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','IMP',
						  'IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
						  'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR',
						  'MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC',
						  'OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC',
						  'SBG','SBM','SBN','SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM',
						  'SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD','VRA',
						  'WBT','WGL','WLG','WLZ','WVO','WWC') then 'MOB'
			 when acna in ('TPM','ACC','ANF','ETL','IPS') then 'TPM'	
				else acna end ID,	
	   ckt_id,
	   report_date
from OSSAMS_MART.TB_DM_OSSAMS_REPAIR_FACT
where acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AZE','BAC',
'BAK','BAO','BCU','BFL','BGH','BPN','BSM','CBL','CCB','CDA','CEO',
'CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
'CSO','CSU','CSX','CTJ','CUO','CZB','DNC','ETP','EST','ETX','FLA',
'FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','IMP',
'IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR',
'MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC',
'OAK','OCL','ORV','OSU','OCK','PFM','PIG','RAD','RMC','RMF','RRC',
'SBG','SBM','SBN','SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM',
'SWP','SWT','SWV','SYC','SZM','TGH','TQU','UMT','VGD','VRA',
'WBT','WGL','WLG','WLZ','WVO','WWC','ATX','TPM','ACC','ANF','ETL','IPS')
and TO_CHAR(AGE_DATE, 'YYYYMMDD') in ('20100201','20100301') --Last data month and current data month 
and TO_CHAR(REPORT_DATE, 'YYYYMMDD') >= '20100201'    ---1st day of last data month   
and circuit_format in ('S','C')
and REPORT_SOURCE = '3'
and REPORT_TYPE = '1'
and INVALID_IND not in ('I')
and substr(MODIFIER,2,1) <> 'U'
and state in ('AZ','ID','IL','IN','MI','NC','NV','OH','OR','SC','WA','WI')
--and state in ('CA','FL','TX')
and DSPSN  in ('4','6','7','9','10','11','12','13','15')
)
order by ckt_id, report_date