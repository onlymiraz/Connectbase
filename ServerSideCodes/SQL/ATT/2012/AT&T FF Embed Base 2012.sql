select * from ossams_mart.tb_dw_ossams_embed_base
where to_char(age_date,'YYYYMMDD') in '20120101'


select acna, sc, sum(embed_base) base
from (
   select c.state, 
   case when service_code = 'HC' then 'DS1'
     when service_code = 'HF' then 'DS3'
	 when service_code like 'X%' then 'DS0'
	 when service_code like 'L%' then 'DS0'
	 when (service_code = 'M8' and carrier_type = 'T1') then 'DS1'
     when (service_code = 'M8' and carrier_type = 'T3') then 'DS3'
	 when service_code like 'K%' then 'Ethernet'
     when service_code like 'V%' then 'Ethernet'
	 when service_code = 'OB' then 'OC3'
	 when service_code = 'OD' then 'OC12'
	 when service_code = 'OF' then 'OC48'
	 when service_code = 'OG' then 'OC192'
	 else service_code end sc,
   case when acna in ('ATX','TPM','AAV','SBB','SBZ','SUV') then 'ATX'
	 when acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
				  'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO') then 'MOB'
	 else acna end acna,	 
     e.embed_base, service_code, class_svc, carrier_type
FROM ossams_mart.tb_dw_ossams_embed_base e,
     ossams_mart.tb_ossams_clli11_lkp c,
     ossams_mart.tb_ossams_district_lkp dis,
     ossams_mart.tb_ossams_division_lkp div,
     ossams_mart.tb_ossams_sub_region_lkp subrg,
     ossams_mart.tb_ossams_region_lkp reg
  where to_char(age_date,'YYYYMMDD') in '20120101'
  and (service_code in ('HC','HF')
   or (substr(service_code,1,1) in ('K','V','L','X')) -- and acna in ('ATX'))
   or (substr(service_code,1,2) in ('OD','OB','OF','OG')) -- and acna in ('ATX'))
   or (service_code = 'M8' and carrier_type in ('T1','T3')))
  and acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN',
               'AIS','AKZ','ALY','AMH','AMP','AWL','AWN','AWS','AZE','BAC','BAK','BAO','BCU',
               'BFL','BGH','BMI','BPN','BSM','CBL','CCB','CDA','CEL','CEO','CEU','CFN','CIV',
               'CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO','CSU','CSX','CTJ','CUO',
               'CUY','CZB','DNC','EKC','ETP','EST','ETX','FLA','FSC','FSI','FSV','GEE','GLV',
               'GSL','HGN','HLU','HNC','HTN','HWC','IMP','IND','ISZ','IUW','JCT','LAA','LAC',
               'LBH','LNZ','LSZ','MBN','MBQ','MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN',
               'MIB','MIR','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW',          
               'OAK','OCL','ORV','OSU','PCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM',
               'SBN','SCU','SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC',
               'SZM','TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO',
               'ATX','TPM','AAV','SBB','SBZ','SUV')
  and c.state in ('AZ','CA','ID','IL','NV','OH','OR','WA','WI') --'IN','MI','NC','SC' 
  and c.district_uid <> '999999'
  and e.clli11_report = c.clli11
  and c.district_uid = dis.district_uid
  and dis.division_uid = div.division_uid
  and div.sub_region_uid = subrg.sub_region_uid
  and subrg.region_uid = reg.region_uid
  )
GROUP by acna, sc
order by acna, sc

