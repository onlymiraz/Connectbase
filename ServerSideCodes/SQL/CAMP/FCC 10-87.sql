

select '2-OR-1' metric, state, prod, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den,
       case when substr(sub_metrics_no,9,4) in ('2100','2200') then 'RES' else 'UNE' end prod   
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('AZ','CA','NV','ID','IL','IN','MI','NC','OH','OR','SC','WA','WI')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('OR-1-04-2100','OR-1-06-2100','OR-1-05-2200','OR-1-07-2200',
                       'OR-1-04-3220','OR-1-06-3220','OR-1-04-3555','OR-1-06-3555')
and dcy_id = '229'
and b.flag = 'FCCPAP'
)
group by state, prod
order by 2, 3



select '3-PR-4' metric, state, prod, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den,
       case when substr(sub_metrics_no,9,4) in ('2100','2200') then 'RES' else 'UNE' end prod   
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('AZ','CA','NV','ID','IL','IN','MI','NC','OH','OR','SC','WA','WI')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('PR-4-01-2200','PR-4-04-2100','PR-4-04-2200','PR-4-05-2100','PR-4-05-2200',
                       'PR-4-04-3555','PR-4-05-3555')
and dcy_id = '229'
and b.flag = 'FCCPAP'
)
group by state, prod
order by 2, 3



select '4-PR-4-02' metric, state, prod, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den,
       case when substr(sub_metrics_no,9,4) in ('2100','2200') then 'RES' else 'UNE' end prod   
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('AZ','CA','NV','ID','IL','IN','MI','NC','OH','OR','SC','WA','WI')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('PR-4-02-2100','PR-4-02-2200','PR-4-02-3555')
and dcy_id = '229'
and b.flag = 'FCCPAP'
)
group by state, prod
order by 2, 3


select '5-PR-6-01' metric, state, prod, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den,
       case when substr(sub_metrics_no,9,4) in ('2100','2200') then 'RES' else 'UNE' end prod   
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('AZ','CA','NV','ID','IL','IN','MI','NC','OH','OR','SC','WA','WI')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('PR-6-01-3220')
and dcy_id = '229'
and b.flag = 'FCCPAP'
)
group by state, prod
order by 2, 3



select '6-PR-6-02' metric, state, prod, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den,
       case when substr(sub_metrics_no,9,4) in ('2100','2200') then 'RES' else 'UNE' end prod   
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('AZ','CA','NV','ID','IL','IN','MI','NC','OH','OR','SC','WA','WI')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('PR-6-02-2100','PR-6-02-3555')
and dcy_id = '229'
and b.flag = 'FCCPAP'
)
group by state, prod
order by 2, 3



select '7-MR-2' metric, state, prod, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den,
       case when substr(sub_metrics_no,9,4) in ('2100','2200') then 'RES' else 'UNE' end prod   
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('AZ','CA','NV','ID','IL','IN','MI','NC','OH','OR','SC','WA','WI')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('MR-2-01-2100','MR-2-01-2200','MR-2-01-3555')
and dcy_id = '229'
and b.flag = 'FCCPAP'
)
group by state, prod
order by 2, 3



select '8-MR-4' metric, state, prod, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den,
       case when substr(sub_metrics_no,9,4) in ('2100','2200') then 'RES' else 'UNE' end prod   
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('AZ','CA','NV','ID','IL','IN','MI','NC','OH','OR','SC','WA','WI')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('MR-4-01-2100','MR-4-01-2200','MR-4-01-3555')
and dcy_id = '229'
and b.flag = 'FCCPAP'
)
group by state, prod
order by 2, 3



select '9-MR-5' metric, state, prod, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den,
       case when substr(sub_metrics_no,9,4) in ('2100','2200') then 'RES' 
	        when substr(sub_metrics_no,9,4) in ('3220') then 'UNE-Spec' else 'UNE-POTs' end prod   
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('AZ','CA','NV','ID','IL','IN','MI','NC','OH','OR','SC','WA','WI')
and a.dcy_id = d.id (+)
and sub_metrics_no in ('MR-5-01-2100','MR-5-01-3220','MR-5-01-3555')
and dcy_id = '229'
and b.flag = 'FCCPAP'
)
group by state, prod
order by 2, 3



select 'PO-3' metric, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den  
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code = 'IN'
and a.dcy_id = d.id (+)
and sub_metrics_no like ('PO-3%')
and dcy_id = '229'
and b.flag = 'JPSAC2C'
)



select 'PO-1' metric, sum(num) num, sum(den) den
from (
select distinct b.sub_metrics_no, a.dcy_id, c.location_code state, a.dte_id, a.numerator num, a.denominator den  
from camp.fact_sub_metrics a, camp.dim_metrics b, camp.dim_geography c, camp.dim_company d
where a.dte_id in ('20130401','20130501','20130601') 
and a.dms_id = b.id
and a.dgy_id = c.id 
and c.location_code in ('AZ','CA','NV','ID','IL','IN','MI','NC','OH','OR','SC','WA','WI')
and a.dcy_id = d.id (+)
and substr(sub_metrics_no,1,7) in ('PO-1-02','PO-1-03','PO-1-04','PO-1-05')
and dcy_id = '229'
and b.flag = 'FCCPAP'
)


