  select service, sum(aiti_bus_days) int, count(*) cnt
   from ( 
	select case when (substr(nc,1,2) = 'HC') then 'MOB DS1'
	   when (substr(nc,1,2) = 'HF') then 'MOB DS3'
	   when substr(nc,1,1) in ('K','V') then 'Ethernet'
	   else 'UNDEFINED' end service,
     aiti_bus_days
    from OSSAMS_MART.TB_DM_OSSAMS_PRVSN_FACT a, OSSAMS_MART.TB_OSSAMS_RCA_DETAIL b
    where a.prvsn_uid = b.record_uid(+)
    and TO_CHAR(LOAD_DATE, 'YYYYMM') = '201202'  ---CHANGE DATES 
    and z_action in ('A','C','I','N','T')
    and invalid_ind not in ('I')
    and to_cd <> ' '
	and substr(clli_z,5,2) in ('AZ','CA','ID','IL','NV','OH','OR','WA','WI') --'IN','MI','NC','SC' 
	and ccna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
	)
	where service <> 'UNDEFINED'
	group by service
	order by service
	



