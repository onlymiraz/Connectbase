drop table attmr  

CREATE TABLE attmr NOLOGGING NOCACHE AS
select case when acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
	case when DSPSN in ('4','6','7','9','10','11','12','15') then 'F'
	     when DSPSN in ('13') then 'NF'
		 end disp,
	 TOTAL_DUR_INT_TIME mttr, TOTAL_DUR_OF_TICKET total_mttr
from OSSAMS_MART.TB_DM_OSSAMS_REPAIR_FACT a,
     ossams_mart.tb_sa_ossams_service_code_lkp b,
     ossams_mart.tb_ossams_tas_code_lkp c,
     ossams_mart.tb_ossams_clli11_lkp d,
     ossams_mart.tb_ossams_service_type e,
     ossams_mart.tb_ossams_district_lkp dis,
     ossams_mart.tb_ossams_division_lkp div,
     ossams_mart.tb_ossams_region_lkp reg,
     ossams_mart.tb_ossams_sub_region_lkp subrg
where TO_CHAR(AGE_DATE, 'YYYYMMDD') in ('20101201')   --CHANGE DATE   
and circuit_format in ('S','C')
and REPORT_SOURCE = '3'
and REPORT_TYPE = '1' 
and INVALID_IND <> 'I'
and substr(MODIFIER,2,1) <> 'U'
and d.state in ('AZ','CA','ID','IL','IN','MI','NC','NV','OH','OR','SC','WA','WI')
and DSPSN  in ('4','6','7','9','10','11','12','13','15')
and acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
or to_char(a.load_date, 'YYYYMMDD') = '20101201'
  and d.state in ('OR', 'WA', 'ID', 'NV', 'AZ', 'CA','MI', 'OH','WI', 'IL', 'IN','SC', 'NC')
  and a.report_source in ('3')
  and a.report_type in ('1')
  and a.dspsn in ('4', '6', '7', '9', '10', '11', '12', '13','15')
  and a.invalid_ind not in ('I')
  and substr(a.modifier,2,1)not in ('U')
  and acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
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
'WBT','WGL','WLG','WLZ','WVO','WWC','ATX')
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




--SQL for results 

select 'MTTR_F', ID||' '||sc svc, round((sum(mttr)/60),2) num, count(*) denom 
from attmr
where disp = 'F'
group by ID, SC
UNION ALL
select 'MTTR_NF', ID||' '||sc svc, round((sum(mttr)/60),2) num, count(*) denom 
from attmr
where disp = 'NF'
group by ID, SC
UNION ALL
select 'MTTR_TOTAL', ID||' '||sc svc, round((sum(total_mttr)/60),2) num, count(*) denom 
from attmr
group by ID, SC
UNION ALL
select 'MTTR_GT4', ID||' '||sc svc, round((sum(mttr)/60),2) num, count(*) denom 
from attmr
where mttr > '240'
group by ID, SC
UNION ALL
select 'TTR_4', ID||' '||sc svc, sum(num) num, sum(denom) denom
from ( 
      --NUMERATOR   
	 select ID, sc, count(*) num, NULL denom
     from attmr
     where mttr <= '240'
     group by ID, sc
     UNION ALL
	  --DENOMINATOR    
     select ID, sc, NULL num, count(*) denom
     from attmr
     group by ID, sc)
group by ID, sc	 
UNION ALL
select 'TTR_8', ID||' '||sc svc, sum(num) num, sum(denom) denom
from ( 
      --NUMERATOR   
	 select ID, sc, count(*) num, NULL denom
     from attmr
     where mttr <= '480'
     group by ID, sc
     UNION ALL
	  --DENOMINATOR    
     select ID, sc, NULL num, count(*) denom
     from attmr
     group by ID, sc)
where sc like '%DS1'
and ID in ('ATX','MOB')
group by ID, sc	
UNION ALL
select 'TTR_12', ID||' '||sc svc, sum(num) num, sum(denom) denom
from ( 
      --NUMERATOR   
	 select ID, sc, count(*) num, NULL denom
     from attmr
     where mttr <= '720'
     group by ID, sc
     UNION ALL
	  --DENOMINATOR    
     select ID, sc, NULL num, count(*) denom
     from attmr
     group by ID, sc)
where sc like '%DS1'
and ID in ('ATX','MOB')
group by ID, sc	
UNION ALL
select 'TTR_24', ID||' '||sc svc, sum(num) num, sum(denom) denom
from ( 
      --NUMERATOR   
	 select ID, sc, count(*) num, NULL denom
     from attmr
     where mttr <= '1440'
     group by ID, sc
     UNION ALL
	  --DENOMINATOR    
     select ID, sc, NULL num, count(*) denom
     from attmr
     group by ID, sc)
where sc like '%DS1'
and ID in ('ATX','MOB')
group by ID, sc	
order by 1,2 