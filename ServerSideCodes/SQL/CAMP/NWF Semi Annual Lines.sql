select state, prod, sum(lines)
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.denominator lines,
case when sub_metrics_no in ('MR-2-01-2100','MR-2-01-2200','MR-2-01-2110','MR-2-01-2120') then 'Resale' else 'UNE' end prod
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20200601') -- Use June or December 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('ID','OR','WA')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('MR-2-01-2100','MR-2-01-2200','MR-2-01-2110','MR-2-01-2120','MR-2-01-3220','MR-2-01-3221','MR-2-01-3223','MR-2-01-3555','MR-2-01-3342','MR-2-01-3344')
and dcy_id = '229'
and flag in ('FCCPAP','JPSAC2C') 
and denominator <> 0
)
group by state, prod
order by 2,1;
 







