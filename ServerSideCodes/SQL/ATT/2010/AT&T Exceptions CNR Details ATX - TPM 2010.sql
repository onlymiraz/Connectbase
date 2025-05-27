--change date in first line of select statement (2x) and in the body (2x)   

select * 
from (
select 'E.2.3', 'DD_NOT_MET', '01-Dec-2010', '31-Dec-2010', 
  case when substr(prchs_order_no,3,1) = 'H' then 'Inter-office Facilities'
	   when substr(nc,1,1) in ('K','V') then 'Wireline Ethernet'
	   when (substr(nc,1,2) in ('OB','JJ') and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC3'
	   when (substr(nc,1,2) in ('OB','JJ') and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX OC3'
	   when (substr(nc,1,2) = 'OD' and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC12'
	   when (substr(nc,1,2) = 'OD' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX OC12'
	   when (substr(nc,1,2) = 'OF' and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC48'
	   when (substr(nc,1,2) = 'OF' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX OC48'
	   when (substr(nc,1,2) = 'OG' and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC192'
	   when (substr(nc,1,2) = 'OG' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX OC192'
	   when (substr(nc,1,1) in ('O','H') and substr(prchs_order_no,3,2) = 'SA') then 'A RING SCI'
	   when (substr(nc,1,1) in ('O') and substr(prchs_order_no,3,2) = 'SR') then 'A RING'
	   when (substr(nc,1,1) in ('L','X') and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL DS0'
	   when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F')) then 'ATX DS1'
	   when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,4,1) in ('P','Y')) then 'TPM DS1'
	   when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,3,1) in ('S','H') and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL DS1'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F')) then 'ATX DS3'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,4,1) in ('P','Y')) then 'TPM DS3'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,3,1) in ('S','H') and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL DS3'
	   else 'UNDEFINED' end service,
	   'FTR13', prchs_order_no, ecckt, ckr, order_no, due_sched_date, dsrd_date, due_cmpln_date, why_miss, NULL,
       prjct_number, rca_detail analysis, app_date	  
from OSSAMS_MART.TB_DM_OSSAMS_PRVSN_FACT a, OSSAMS_MART.TB_OSSAMS_RCA_DETAIL b
where a.prvsn_uid = b.record_uid(+)
and TO_CHAR(LOAD_DATE, 'YYYYMM') = '201012'
and substr(clli_z,5,2) in ('AZ','CA','ID','IL','IN','MI','NC','NV','OH','OR','SC','WA','WI')
and z_action in ('A','C','I','N','T')
and invalid_ind not in ('I')
and to_cd <> ' '
and ccna in ('ATX','TPM')
and (substr(why_miss,1,1) in ('C','D','R') or substr(why_miss,1,4) = 'KN16')
UNION ALl
select 'E.2.3', 'DD_NOT_MET', '01-Dec-2010', '31-Dec-2010', 
  case when (substr(nc,1,2) = 'HC') then 'MOB DS1'
	   when (substr(nc,1,2) = 'HF') then 'MOB DS3'
	   else 'UNDEFINED' end service,
	   'FTR13', prchs_order_no, ecckt, ckr, order_no, due_sched_date, dsrd_date, due_cmpln_date, why_miss, NULL,
       prjct_number, rca_detail analysis, app_date	  
from OSSAMS_MART.TB_DM_OSSAMS_PRVSN_FACT a, OSSAMS_MART.TB_OSSAMS_RCA_DETAIL b
where a.prvsn_uid = b.record_uid(+)
and TO_CHAR(LOAD_DATE, 'YYYYMM') = '201012'
and substr(clli_z,5,2) in ('AZ','CA','ID','IL','IN','MI','NC','NV','OH','OR','SC','WA','WI')
and (substr(nc,1,2) in ('HF','HC')
   or substr(nc,1,1) in ('K','V'))
and z_action in ('A','C','I','N','T')
and invalid_ind not in ('I')
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
and (substr(why_miss,1,1) in ('C','D','R') or substr(why_miss,1,4) = 'KN16')
)
where service <> 'UNDEFINED'
order by service


