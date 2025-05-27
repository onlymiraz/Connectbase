select region, state, ID||sc prod, ckt_id, disp, report_date, TOTAL_DUR_INT_TIME
from (
select a.state,
       case when a.state in ('IL','IN','MI','OH','WI') then 'MW'
	        when a.state in ('NC','SC') then 'SE'
			when a.state in ('AZ','CA','ID','WA','OR') then 'WC'
			else a.state end region,
	   case when acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
			 when acna in ('ATX','TPM','AAV','SBB','SBZ','SUV') then 'ATX'	
				else acna end ID,	
		case when a.service_code = 'HC' then 'DS1'
	   		when a.service_code = 'HF' then 'DS3'
			when a.service_code like 'K%' then 'Ethernet'
			when a.service_code like 'V%' then 'Ethernet'
			when a.service_code like 'L%' then 'DS0'
			when a.service_code like 'X%' then 'DS0'
			when a.service_code = 'OB' then 'OC3'
			when a.service_code = 'OD' then 'OC12'
			when a.service_code = 'OF' then 'OC48'
			when a.service_code = 'OG' then 'OC192'
			when (a.service_code = 'M8' and carrier_type = 'T1') then 'DS1'
		    when (a.service_code = 'M8' and carrier_type = 'T3') then 'DS3'
			when ckt_id like '%T1%' then 'DS1'
			when ckt_id like '%T3%' then 'DS3'
		else a.service_code end sc,
	   ckt_id, 
	   case when dspsn in ('4','6','7','9','10','11','12','15') then 'F'
	    else 'NF' end disp,
	   report_date, TOTAL_DUR_INT_TIME
from OSSAMS_MART.TB_DM_OSSAMS_REPAIR_FACT a,
     ossams_mart.tb_sa_ossams_service_code_lkp b,
     ossams_mart.tb_ossams_tas_code_lkp c,
     ossams_mart.tb_ossams_clli11_lkp d,
     ossams_mart.tb_ossams_service_type e,
     ossams_mart.tb_ossams_district_lkp dis,
     ossams_mart.tb_ossams_division_lkp div,
     ossams_mart.tb_ossams_region_lkp reg,
     ossams_mart.tb_ossams_sub_region_lkp subrg
where TO_CHAR(AGE_DATE, 'YYYYMM') in ('201201','201202') --Last data month and current data month 
and TO_CHAR(REPORT_DATE, 'YYYYMMDD') >= '20120101'    ---1st day of Last data month     
and circuit_format in ('S','C')
and REPORT_SOURCE = '3'
and REPORT_TYPE = '1' 
and INVALID_IND <> 'I'
and substr(MODIFIER,2,1) <> 'U'
and d.state in ('AZ','CA','ID','IL','NV','OH','OR','WA','WI') --'IN','MI','NC','SC' 
and DSPSN  in ('4','6','7','9','10','11','12','13','15')
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
and a.state = c.state
  and a.cntrl_offce = c.cntrl_offce
  and c.clli11 = d.clli11
  and d.district_uid not in ('999999')
  and d.district_uid = dis.district_uid
  and dis.division_uid = div.division_uid
  and div.sub_region_uid = subrg.sub_region_uid
  and div.region_uid = reg.region_uid
  and b.service_type in ('D7', 'A6', 'D6', 'S1')
  and b.st_category in ('Z')
  and a.service_code = b.service_code
  and b.service_type = e.service_type
or TO_CHAR(AGE_DATE, 'YYYYMM') in ('201201','201202') --Last data month and current data month 
  and TO_CHAR(REPORT_DATE, 'YYYYMMDD') >= '20120101'    ---1st day of Last data month    
  and d.state in ('AZ','CA','ID','IL','NV','OH','OR','WA','WI') --'IN','MI','NC','SC' 
  and a.report_source in ('3')
  and a.report_type in ('1')
  and a.dspsn in ('4', '6', '7', '9', '10', '11', '12', '13','15')
  and a.invalid_ind not in ('I')
  and substr(a.modifier,2,1)not in ('U')
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
  and a.state = c.state
  and a.cntrl_offce = c.cntrl_offce
  and c.clli11 = d.clli11
  and d.district_uid not in ('999999')
  and d.district_uid = dis.district_uid
  and dis.division_uid = div.division_uid
  and div.sub_region_uid = subrg.sub_region_uid
  and div.region_uid = reg.region_uid
  and b.service_type in ('8')
  and b.st_category in ('Z')
  and a.service_code = b.service_code
  and b.service_type = e.service_type
  and (a.service_code='M8' and substr(a.ckt_id,2,7) LIKE '%T1%'
   or substr(a.ckt_id,2,7) LIKE '%T3%'
   or substr(a.ckt_id,2,7) LIKE '%OC3%'
   or substr(a.ckt_id,2,7) LIKE '%T04%'
   or substr(a.ckt_id,2,7) LIKE '%OC03%'
   or substr(a.ckt_id,2,7) LIKE '%OC12%'
   or substr(a.ckt_id,2,7) LIKE '%OC24%'
   or substr(a.ckt_id,2,7) LIKE '%OC48%'
   or substr(a.ckt_id,2,7) LIKE '%OC192%')
 )
order by ckt_id, report_date

