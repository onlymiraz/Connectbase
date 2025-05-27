-- For RFR ***CHANGE DATE ***  
select measure, ID||' '||sc svc, sum(num) num, sum(trbls) trbls
from (
select 'RFR' measure, ID, sc, NULL num, count(*) trbls
from (
select case when acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
		repair_uid, load_date, ckt_id, dspsn, service_code, acna, invalid_ind
from OSSAMS_MART.TB_DM_OSSAMS_REPAIR_FACT
where TO_CHAR(AGE_DATE, 'YYYYMMDD') = '20110801'   --CHANGE DATE   
and circuit_format in ('S','C')
and REPORT_SOURCE = '3'
and REPORT_TYPE = '1'
and INVALID_IND <> 'I'
and state in ('AZ','CA','ID','IL','IN','MI','NC','NV','OH','OR','SC','WA','WI')
and DSPSN  in ('4','6','7','9','10','11','12','13','15')
and acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
'WBT','WGL','WLG','WLZ','WVO','WWC','ATX','TPM','ACC','ANF','ETL','IPS'))
group by ID, sc)
group by measure, ID, sc
order by svc

