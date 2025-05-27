

select state, 'Resale' PROD, count(*) 
from (
select distinct phone_number, state
from camp.DPI_ACCESS_LINES_IN_SERVICE
where rpt_mnth_year = '202006'  -- USE JUNE OR DECEMBER  
and state in ('ID','OR','WA')
and (service_and_equipment like '%69328%'
or service_and_equipment like '%69329%'
or service_and_equipment like '%69330%'
or service_and_equipment like '%69333%'
or service_and_equipment like '%69334%'
or service_and_equipment like '%69552%'
or service_and_equipment like '%6955B%'   
or service_and_equipment like '%6955C%'  
or service_and_equipment like '%6932P%'
or service_and_equipment like '%6942P%'
or service_and_equipment like '%89187%'
or service_and_equipment like '%89188%'
or service_and_equipment like '%UNPPU%'
or service_and_equipment like '%PLATU%')
and ccna is not null
)
group by state 
order by 1;
