
-- Resale to WSA
select * 
from USER_WORK.CM_WSA_RESALE
where data_month in ('2022-12-01','2023-01-01')
and wtn in (
select wtn
from USER_WORK.CM_WSA_RESALE
where data_month = '2023-01-01'
and product = 'WSA'
and wtn in (
select wtn from USER_WORK.CM_WSA_RESALE
where data_month = '2022-12-01'
and product = 'RESALE'
))
order by wtn, data_month;


-- WSA to Resale
select * 
from USER_WORK.CM_WSA_RESALE
where data_month in ('2022-12-01','2023-01-01')
and wtn in (
select wtn
from USER_WORK.CM_WSA_RESALE
where data_month = '2023-01-01'
and product = 'RESALE'
and wtn in (
select wtn from USER_WORK.CM_WSA_RESALE
where data_month = '2022-12-01'
and product = 'WSA'
))
order by wtn, data_month;


