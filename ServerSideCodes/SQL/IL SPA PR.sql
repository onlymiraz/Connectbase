
select age_date, prvsn_uid, load_date, invalid_ind, efctv_cmpln_date, substr(clli_report,5,2) state, 
       case when service_code = 'HC' then 'DS1'
	        when service_code = 'HF' then 'DS3'
			when service_code like 'L%' then 'DS0'
			when service_code like 'X%' then 'DS0'
			else service_code end svc_type, 
       case when (efctv_cmpln_date > due_sched_date and substr(why_miss,1,2) not in ('CN','RN','KN','NN','DP')) 
	   then 0 else 1 end Num, 
	   1 Den, ecckt, modifier,
	   ckr, order_no, due_sched_date, dsrd_date, due_cmpln_date, why_miss, clli_a, clli_z, 
	   customer2 carrier, ccna, prjct_ind, service_code, service_code1, z_action, nc, nci, class_svc, app_date   
	from OSSAMS_MART.TB_DM_OSSAMS_PRVSN_FACT a, ossams_mart.tb_dm_ossams_acna_lkp b
    where a.acna = b.acna
    and TO_CHAR(LOAD_DATE, 'YYYYMM') = '201202'  ---CHANGE DATES 
    and modifier = 'FS'
    and z_action in ('A','C','I','N','T')
    and invalid_ind not in ('I')
    and to_cd <> ' '
	and substr(clli_z,5,2) = 'IL'
	and a.ccna not in ('CUS') --,'EBA','PPM','GMT')
	order by 1,2
   
   
