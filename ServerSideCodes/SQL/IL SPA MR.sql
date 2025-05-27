
select age_date, repair_uid,load_date,invalid_ind,
 case when total_dur_int_time > 480 then 1
      else 0 end OOS8,
	 total_dur_int_time/60 MTTR, 1 count,state,lkp.customer2, rep.acna,
	 case when service_code = 'HC' then 'DS1'
	      when service_code = 'HF' then 'DS3'
	      when service_code like 'L%' then 'DS0'
		  when service_code like 'X%' then 'DS0'
		  else service_code end svc_type, 
	 ckt_id, service_code, modifier, report_date, commit_date, cleared_date,
	 dspsn, dspsn_subcd, tas_serial
from
OSSAMS_MART.TB_DM_OSSAMS_REPAIR_FACT rep, ossams_mart.tb_dm_ossams_acna_lkp lkp 
where rep.acna = lkp.acna
and TO_CHAR(AGE_DATE, 'YYYYMM') = '201202'   --CHANGE DATE   
and state = 'IL'
and REPORT_SOURCE = '3'
and REPORT_TYPE = '1' 
and INVALID_IND <> 'I'
and substr(MODIFIER,2,1) <> 'U'
and DSPSN  in ('4','6','7','9','10','11','12','13','15')
and modifier = 'FS'
and rep.acna not in ('CUS') --,'EBA','PPM','GMT') 
order by 1, 2 



---IL SPA MR-2 Numerator  
select count(*)
from
OSSAMS_MART.TB_DM_OSSAMS_REPAIR_FACT rep, ossams_mart.tb_dm_ossams_acna_lkp lkp 
where rep.acna = lkp.acna
and TO_CHAR(AGE_DATE, 'YYYYMM') = '201202'   --CHANGE DATE   
and state = 'IL'
and REPORT_SOURCE = '3'
and REPORT_TYPE = '1' 
and INVALID_IND <> 'I'
and substr(MODIFIER,2,1) <> 'U'
and DSPSN  in ('4','6','7','9','10','11','12')
and modifier = 'FS'
and rep.acna not in ('CUS') --,'EBA','PPM','GMT') 
