select state, prod, sum(den) cnt 
from (
select dw_st_cd STATE, SUB_MTRC_NO, CLEC_DNMNTR_VAL DEN,
       case when substr(SUB_MTRC_NO,9,1) = '2' then 'Resale'
       else 'UNE' end prod
from C2C_CPODS_VWMC.C2C_RPT_FCT_SUB_MTRC
where yr_mth_no = '202306'
and sub_mtrc_no in ('MR-2-01-2100','MR-2-01-2200','MR-2-01-3220','MR-2-01-3555','MR-2-01-3344')
and clec_cd = 'ALL'
and dw_st_cd = 'OH'
UNION ALL
select dw_st_cd STATE, SUB_MTRC_NO, CLEC_DNMNTR_VAL DEN,
       case when substr(SUB_MTRC_NO,9,1) = '2' then 'Resale'
       else 'UNE' end prod
from C2C_CPODS_VWMC.C2C_RPT_FCT_SUB_MTRC
where yr_mth_no = '202306'
and sub_mtrc_no in ('MR-2-01-2100','MR-2-01-2200','MR-2-01-2110','MR-2-01-2120','MR-2-01-3220',
                    'MR-2-01-3221','MR-2-01-3223','MR-2-01-3555','MR-2-01-3342','MR-2-01-3344')
and clec_cd = 'ALL'
and dw_st_cd not in ('OH','WV')
UNION ALL
select dw_st_cd STATE, SUB_MTRC_NO, CLEC_DNMNTR_VAL DEN,
       case when substr(SUB_MTRC_NO,9,1) = '2' then 'Resale'
       else 'UNE' end prod
from C2C_CPODS_VWMC.C2C_RPT_FCT_SUB_MTRC
where yr_mth_no = '202306'
and sub_mtrc_no in ('MR-2-02-2100','MR-2-02-2341','MR-2-02-3112','MR-2-02-3341','MR-2-02-3342')
and clec_cd = 'ALL'
and dw_st_cd = 'WV'
) ORIG
group by state, prod
order by 1,2;

;


Still need to run IL separately from the Semi-Annual Lines.sql


