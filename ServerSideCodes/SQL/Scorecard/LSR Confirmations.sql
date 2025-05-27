
select sum(num), sum(den), sum(num)/sum(den)*100 res
from (
select count(*) num, null den
from dm_wst_app.TB_DM_ORD_LSR_FACT a
where project_fl = 'N'
and event_cd = 'C'
and exclusion_ind = 'N'
and handle_code <> 'EREH'
and ontime_ind = 'Y'
and to_char(true_event_date,'YYYYMMDD') between '20120129' and '20120204' 
and sgt_prod not in 'UNE-PLATP'
UNION ALL
select null num, count(*) den
from dm_wst_app.TB_DM_ORD_LSR_FACT a
where project_fl = 'N'
and event_cd = 'C'
and exclusion_ind = 'N'
and handle_code <> 'EREH'
and to_char(true_event_date,'YYYYMMDD') between '20120129' and '20120204' 
and sgt_prod not in 'UNE-PLATP'
)


select distinct trunc(true_event_date)
from dm_wst_app.TB_DM_ORD_LSR_FACT
where to_char(true_event_date,'YYYYMMDD') between '20120101' and '20120131'