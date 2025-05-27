-- *** Change two (2) dates *** 
select mon, region, service, sum(missed) missed, sum(total) total
from ( 
  --NUMERATOR  
  select mon, region, service, count(*) missed, NULL total
  from (
    select case when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F')) then 'ATX DS1'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F')) then 'ATX DS3'
	   else 'UNDEFINED' end service,
      case when (substr(why_miss,1,1) in ('C','D','R') or substr(why_miss,1,4) = 'KN16') then 'MET'
  	   when due_cmpln_date - dsrd_date <= 0 then 'MET'
	   else 'MISS' end CDDD_Met, 
	   case when substr(clli_z,5,2) in ('NC','SC') then 'Southeast'
	        when substr(clli_z,5,2) in ('WA','CA','OR') then 'West'
			when substr(clli_z,5,2) in ('IL','OH') then 'Central'
			when substr(clli_z,5,2) in ('IN','MI') then 'Midwest'
			else 'National' end region, TO_CHAR(LOAD_DATE, 'YYYYMM') mon
    from OSSAMS_MART.TB_DM_OSSAMS_PRVSN_FACT a, OSSAMS_MART.TB_OSSAMS_RCA_DETAIL b
    where a.prvsn_uid = b.record_uid(+)
    and TO_CHAR(LOAD_DATE, 'YYYY') = '2011'  ---CHANGE DATES 
    and z_action in ('A','C','I','N','T')
    and invalid_ind not in ('I')
    and to_cd <> ' '
	and substr(clli_z,5,2) in ('AZ','CA','ID','IL','IN','MI','NC','NV','OH','OR','SC','WA','WI')
	and ccna in ('ATX','TPM','ACC','ANF','ETL','IPS'))
   where CDDD_MET = 'MISS'
   group by mon, region, service
  UNION ALL
  -- DENOMINATOR  
  select mon, region, service, NULL missed, count(*) total
  from (
    select case when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F')) then 'ATX DS1'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F')) then 'ATX DS3'
	   else 'UNDEFINED' end service,
      case when (substr(why_miss,1,1) in ('C','D','R') or substr(why_miss,1,4) = 'KN16') then 'MET'
  	   when due_cmpln_date - dsrd_date <= 0 then 'MET'
	   else 'MISS' end CDDD_Met,
	  case when substr(clli_z,5,2) in ('NC','SC') then 'Southeast'
	        when substr(clli_z,5,2) in ('WA','CA','OR') then 'West'
			when substr(clli_z,5,2) in ('IL','OH') then 'Central'
			when substr(clli_z,5,2) in ('IN','MI') then 'Midwest'
			else 'National' end region, TO_CHAR(LOAD_DATE, 'YYYYMM') mon
    from OSSAMS_MART.TB_DM_OSSAMS_PRVSN_FACT a, OSSAMS_MART.TB_OSSAMS_RCA_DETAIL b
    where a.prvsn_uid = b.record_uid(+)
    and TO_CHAR(LOAD_DATE, 'YYYY') = '2011'   ---CHANGE DATES  
    and z_action in ('A','C','I','N','T')
    and invalid_ind not in ('I')
    and to_cd <> ' '
	and substr(clli_z,5,2) in ('AZ','CA','ID','IL','IN','MI','NC','NV','OH','OR','SC','WA','WI')
    and ccna in ('ATX','TPM','ACC','ANF','ETL','IPS'))
   group by mon, region, service)
  where service <> 'UNDEFINED' 
group by mon, region, service
order by mon, service, region


Ethernet can be SD or SE REQ Types - do not have the SEI field though.