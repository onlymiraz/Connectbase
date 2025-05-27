select add_months(data_month,1) data_month, product, carrier, state, count(*)
from USER_WORK.CM_WSA_RESALE
where data_month = '2022-12-01'
and product = 'WSA'
and wtn not in (
select wtn from USER_WORK.CM_WSA_RESALE
where data_month = '2023-01-01'
)
group by data_month, product, carrier, state
order by 1,2,3,4;