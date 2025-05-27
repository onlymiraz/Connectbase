select distinct b.sub_metrics_no, b.c2c_product_desc, a.dcy_id, c.location_code, a.dte_id, a.numerator, a.denominator, 
       case when a.denominator >0 then (a.numerator/a.denominator)*100 else null end result 
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20200101') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('OR')
and a.dcy_id = d.id (+)
and sub_metrics_no like 'PR-7-%-3555'
--and dcy_id = '229'
and flag = 'JPSAC2C'   --FCCPAP'
and denominator > 0
order by 1,2,3;



select metric, prod, state, month, sum(num) clec_num, sum(den) clec_den,
       case when sum(den) > 0 then (sum(num)/sum(den))*100 else null end clec_res,
       sum(ilec_num) ilec_num, sum(ilec_den) ilec_den,
	   case when sum(ilec_den) > 0 then (sum(ilec_num)/sum(ilec_den))*100 else null end ilec_res
from (
select distinct b.sub_metrics_no metric, b.c2c_product_desc prod, c.location_code state, a.dte_id month, a.numerator num, a.denominator den, 
       null ilec_num, null ilec_den    
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20120801') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('OR')
and a.dcy_id = d.id (+)
and dcy_id = '229'
and flag = 'JPSAC2C'
UNION ALL
select distinct b.sub_metrics_no metric, b.c2c_product_desc prod, c.location_code state, a.dte_id month, null num, null den, 
       a.numerator ilec_num, a.denominator ilec_den 
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20120801') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('OR')
and a.dcy_id = d.id (+)
and dcy_id = '100'
and flag = 'JPSAC2C'
)
group by metric, prod, state, month
order by 1
