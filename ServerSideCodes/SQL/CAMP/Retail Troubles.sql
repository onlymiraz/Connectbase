select *
from camp.num_den_query
where sub_metrics_no = 'MR-2-01-3221'
and state_code = 'OR' and year_month_code = '201502'


select line_id, z.dw_state, prod_grp, fld_faultcode_numeric,FLD_EVENTSTARTTIME,FLD_CUSTOMERASSETNO,FLD_CLEAREDDATETIME,FLD_CLOSEDDATETIME,COMMITMENT_TIME_X,FLD_CUSTOMERASSETPRIMARYATTRIB,
       CUSTOMER_MISS,y.DW_STATE,DW_COMPANY,DW_PRODUCT_ID,OUT_OF_SERVICE,FLD_CATEGORY,SOURCE_CODE,PRIMARY_CIRCUIT_LCDSM,DISPATCH_VALUE,PRODUCT_GROUP,USOC, fld_category, official_line_ind
from ( 
SELECT line_id, dw_state, product_group prod_grp
FROM camp.VW_MR_2_01_DEN_F13 
WHERE product_group in ('2210_R','2211_R','2213_R','2200_R')  
AND((((nc NOT LIKE 'L%' and nc NOT LIKE 'X%') OR nc like 'LX%')
      AND NC not LIKE 'HC%'
      and NC not LIKE 'HF%'
      and NC not LIKE 'O%'
      and NC not LIKE 'K%'
      and NC not LIKE 'V%')or nc is null)
     AND (SUBSTR (TRIM (line_id), 4, 2) not in ('HC', 'HF') OR LINE_ID IS NULL)
and DW_COMPANY ='100' 
and dw_state in ('OR','WA') 
and  DW_RPT_MON_YEAR ='022015'
) z, camp.vw_ods_trouble_tickets_mr y
where z.line_id = y.fld_customerassetprimaryattrib
and dw_rpt_mon_year = '022015'
	 
	 
SELECT * 
FROM VW_MR_2_01_2200_F13 WHERE (SUBSTR(FLD_FAULTCODE_NUMERIC,1,2) IN ('03','04','05','07')  AND FLD_CLOSEDDATETIME IS NOT NULL ) and DW_COMPANY ='100' and dw_state='OR' and DW_RPT_MON_YEAR ='022015' 

SELECT * --COUNT(DISTINCT FLD_REQUESTID) NUM 
FROM camp.VW_MR_2_01_3223_F13  WHERE DW_RPT_MON_YEAR ='022015' --(SUBSTR(FLD_FAULTCODE_NUMERIC,1,2) IN ('03','04','05','07')  AND FLD_CLOSEDDATETIME IS NOT NULL ) and DW_COMPANY ='100' and dw_state='OR' and DW_RPT_MON_YEAR ='022015'


select *
from camp.VW_ODS_TROUBLE_TICKETS_MR