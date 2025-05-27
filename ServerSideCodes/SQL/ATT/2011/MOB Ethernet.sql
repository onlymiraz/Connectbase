select asr_no, acna, act, app_dt, ccna, d_dstat, d_rec, dd, ddd, nc_cd, substr(nc_cd,1,1) nc, pon, svc_st, ecckt, asr_cd comp_dt, ord, 
case when asr_cd > ddd then 'MISS' else 'MET' end Status
from naccprod.asr_dim
where to_char(asr_cd,'yyyymm') = '201110'
and substr(nc_cd,1,1) in ('K','V') 
and act <> 'D'
and stat <> 'CAN'
and ccna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
			 'WBT','WGL','WLG','WLZ','WVO','WWC')