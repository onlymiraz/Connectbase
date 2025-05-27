-- *** Change TWO (2) dates *** 
-- *******************************   ONE MONTH IN ARREARS    *****************************************

  select service, count(prvsn_uid) failures
  from (
    select distinct prvsn_uid,  
	  case when substr(prchs_order_no,3,1) = 'H' then 'Inter-office Facilities'
	   when (substr(nc,1,1) in ('K','V')) then 'Ethernet'
	   when (substr(nc,1,2) in ('OB','JJ') and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC3'
	   when (substr(nc,1,2) in ('OB','JJ') and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL OC3'
	   when (substr(nc,1,2) = 'OD' and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC12'
	   when (substr(nc,1,2) = 'OD' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL OC12'
	   when (substr(nc,1,2) = 'OF' and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC48'
	   when (substr(nc,1,2) = 'OF' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL OC48'
	   when (substr(nc,1,2) = 'OG' and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC192'
	   when (substr(nc,1,2) = 'OG' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL OC192'
	   when (substr(nc,1,1) in ('O','H') and substr(prchs_order_no,3,2) = 'SA') then 'A RING SCI'
	   when (substr(nc,1,1) in ('O') and substr(prchs_order_no,3,2) = 'SR') then 'A RING'
	   when (substr(nc,1,1) in ('L','X') and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL DS0'
	   when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F') and prv.acna = 'ATX') then 'ATX DS1'
	   when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,4,1) in ('P','Y') and prv.acna in ('ATX','TPM','AAV','SBB','SBZ','SUV')) then 'ATX DS1'
	   when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,3,1) in ('S','H') and substr(prchs_order_no,4,1) <> 'A' and prv.acna = 'ATX') then 'ATX ALL DS1'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F') and prv.acna = 'ATX') then 'ATX DS3'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,4,1) in ('P','Y') and prv.acna in ('ATX','TPM','AAV','SBB','SBZ','SUV')) then 'ATX DS3'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,3,1) in ('S','H') and substr(prchs_order_no,4,1) <> 'A' and prv.acna = 'ATX') then 'ATX ALL DS3'
	   when (substr(nc,1,2) = 'HF' 
	       and prv.acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
						  'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO')) then 'MOB DS3'
	   when (substr(nc,1,2) = 'HC' 
	       and prv.acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
						  'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO')) then 'MOB DS1'
	    when (substr(nc,1,1) in ('K','V')
		   and prv.acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
						  'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO')) then 'MOB Ethernet'	 			 	 
	   else 'UNDEFINED' end service
    from OSSAMS_MART.TB_DM_OSSAMS_REPAIR_FACT rep, OSSAMS_MART.TB_DM_OSSAMS_PRVSN_FACT prv
where prv.ecckt = rep.ckt_id(+)
and TO_CHAR(prv.LOAD_DATE, 'YYYYMM') = '201201'  --CHANGE DATES (Month in arrears)   
and prv.z_action in ('A','C','I','N','T')
and prv.invalid_ind not in ('I')
and prv.to_cd <> ' '
and substr(prv.clli_z,5,2) in ('AZ','CA','ID','IL','NV','OH','OR','WA','WI') --'IN','MI','NC','SC' 
and prv.ccna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN',
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
and TO_CHAR(rep.REPORT_DATE,'YYYYMMDD') between '20120101' and '20120229'  --CHANGE DATES  Current Month (in arrears) through Next Month   
and TO_CHAR(rep.REPORT_DATE,'YYYYMMDD') >= TO_CHAR(prv.EFCTV_CMPLN_DATE,'YYYYMMDD') 
and rep.REPORT_DATE - prv.EFCTV_CMPLN_DATE <=30  
and rep.circuit_format in ('S','C')
and rep.REPORT_SOURCE = '3'
and rep.REPORT_TYPE = '1' 
and rep.INVALID_IND <> 'I'
and rep.state in ('AZ','CA','ID','IL','NV','OH','OR','WA','WI') --'IN','MI','NC','SC' 
and rep.DSPSN  in ('4','6','7','9','10','11','12','15')
and rep.ACNA in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN',
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
             'ATX','TPM','AAV','SBB','SBZ','SUV'))
group by service
order by service



