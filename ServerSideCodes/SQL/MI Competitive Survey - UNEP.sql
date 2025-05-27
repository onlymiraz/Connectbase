
select npanxx, serv_type, count(*)
from (
select substr(phone_number,1,6) npanxx, 
       case when service_type = 'LR' then 'Res'
	   else 'Bus' end serv_type
from camp.DPI_ACCESS_LINES_IN_SERVICE
where rpt_mnth_year = '201201'
and state = 'MI'
and (service_and_equipment like '%69328%'
or service_and_equipment like '%69329%'
or service_and_equipment like '%69330%'
or service_and_equipment like '%69333%'
or service_and_equipment like '%69334%'
or service_and_equipment like '%69552%'
or service_and_equipment like '%6932P%'
or service_and_equipment like '%6942P%'
or service_and_equipment like '%89187%'
or service_and_equipment like '%89188%'
or service_and_equipment like '%UNPPU%'
or service_and_equipment like '%PLATU%'
)
and ccna is not null
)
group by npanxx, serv_type
order by 1, 2


