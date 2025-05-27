-- CHANGE DATE  


select * from
(
select substr(clli_z,5,2) state,
  case when (substr(nc,1,2) = 'HC') then 'MOB DS1'
	   when (substr(nc,1,2) = 'HF') then 'MOB DS3'
	   else 'UNDEFINED' end service,
	   prchs_order_no, ecckt, ckr, order_no,
	   due_cmpln_date - dsrd_date CDDD_to_CD, due_sched_date, dsrd_date, due_cmpln_date, why_miss, clli_a, clli_z,
	   ccna, prjct_ind, prjct_number, service_code, service_code1, modifier, z_action, nc, nci, app_date
from OSSAMS_MART.TB_DM_OSSAMS_PRVSN_FACT a, OSSAMS_MART.TB_OSSAMS_RCA_DETAIL b
where a.prvsn_uid = b.record_uid(+)
and TO_CHAR(LOAD_DATE, 'YYYYMMDD') between '20100301' and '20100331'
and (substr(nc,1,2) in ('HF','HC')
   or substr(nc,1,1) in ('K','V'))
and z_action in ('A','C','I','N','T')
and invalid_ind not in ('I')
and substr(clli_z,5,2) in ('CA','FL','TX')
and to_cd <> ' '
and ccna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
			 'WBT','WGL','WLG','WLZ','WVO','WWC')
)
where service <> 'UNDEFINED'
order by service, prchs_order_no


