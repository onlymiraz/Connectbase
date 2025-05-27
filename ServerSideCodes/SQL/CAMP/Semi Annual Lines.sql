--Likely will use the data from the CTF Semi-Annual Lines file - as the data is now in Teradata.  

select state, prod, sum(lines)
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.denominator lines,
case when sub_metrics_no in ('MR-2-01-2100','MR-2-01-2200','MR-2-01-2110','MR-2-01-2120') then 'Resale' else 'UNE' end prod
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20230601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code not in ('OH')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('MR-2-01-2100','MR-2-01-2200','MR-2-01-2110','MR-2-01-2120','MR-2-01-3220','MR-2-01-3221','MR-2-01-3223','MR-2-01-3555','MR-2-01-3342','MR-2-01-3344')
and dcy_id = '229'
and flag in ('FCCPAP','JPSAC2C') 
and denominator <> 0
UNION ALL
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.denominator lines,
case when sub_metrics_no in ('MR-2-01-2100','MR-2-01-2200','MR-2-01-2110','MR-2-01-2120') then 'Resale' else 'UNE' end prod
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20230601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('OH')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('MR-2-01-2100','MR-2-01-2200','MR-2-01-3220','MR-2-01-3555','MR-2-01-3344')
and dcy_id = '229'
and flag in ('FCCPAP') 
and denominator <> 0
UNION ALL
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.denominator lines,
case when sub_metrics_no in ('MR-2-02-2100','MR-2-02-2341') then 'Resale' 
     when sub_metrics_no in ('MR-2-01-2200') then 'Resale Specials' else 'UNE' end prod
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20230601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('WV')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('MR-2-02-2100','MR-2-02-2341','MR-2-02-3112','MR-2-02-3341','MR-2-02-3342','MR-2-01-3200')
and dcy_id = '229'
and flag = 'C2C'  
and denominator <> 0
)
group by state, prod
order by 2,1;


-- For Illinois - to be done in ODS   
select product_group, count(*) 
from camp.ODS_ACCESS_LINES_IN_SERVICE OA, camp.VW_USOC_PRODUCT VPU
  WHERE OA.CLASS_OF_SERVICE = VPU.USOC
and service_addr_state = 'IL'
and UPPER (ASSET_STATUS) = 'ACTIVE'
    AND NOT (UPPER (NVL (OA.CUSTOMER_ACCOUNT_TYPE, 0)) = 'COMPANY'
    AND UPPER (NVL (OA.CUSTOMER_ACCOUNT_SUB_TYPE, 0)) in ('INTERNAL', 'COIN PUBLIC'))
	and rpt_month_year = '062023'
	and wholesale_ccna_acna is not null
	and product_group in ('2100_W','3220_W','3555_W','3344_W')
group by product_group	
UNION ALL
select product_group, count(*) 
from camp.ODS_ACCESS_LINES_IN_SERVICE OA, camp.VW_USOC_PRODUCT VPU
  WHERE OA.CLASS_OF_SERVICE = VPU.USOC
and service_addr_state = 'IL'
and UPPER (ASSET_STATUS) = 'ACTIVE'
    AND NOT (UPPER (NVL (OA.CUSTOMER_ACCOUNT_TYPE, 0)) = 'COMPANY'
    AND UPPER (NVL (OA.CUSTOMER_ACCOUNT_SUB_TYPE, 0)) in ('INTERNAL', 'COIN PUBLIC'))
	and rpt_month_year = '062023'
	and wholesale_ccna_acna is not null
	and product_group in ('2200_W')
	and class_of_service = 'FTR220x'
	and wholesale_ccna_acna <> '100'
group by product_group
order by 1; 







