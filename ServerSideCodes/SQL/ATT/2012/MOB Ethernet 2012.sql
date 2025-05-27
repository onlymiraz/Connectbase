select distinct d.asr_no, d.acna, d.act, d.d_rec, asr_last_foc_dt,  d.dd, d.ddd,
case when substr(d.nc_cd,1,1) = 'V' then 'EVC' else 'Cell' end prod, 
d.pon, d.svc_st, d.ecckt, d.asr_cd comp_dt, ord,
case when asr_last_foc_dt-d.d_rec <= 10 then 'MET' else 'MISS' end FOC,
case when d.asr_cd > d.dd then 'MISS' else 'MET' end CDDStatus,
case when d.asr_cd > d.ddd then 'MISS' else 'MET' end CDDDStatus
from naccprod.asr_dim d, naccprod.asr_interval i
where d.asr_no = i.asr_no
and d.asr_id = i.asr_id 
and to_char(asr_cd,'yyyymm') = '201201'
and substr(d.nc_cd,1,1) in ('K','V') 
and d.act <> 'D'
and d.stat <> 'CAN'
and d.ccna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
and d.version = 0