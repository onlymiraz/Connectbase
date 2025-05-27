


select state, count(*) 
from (
select distinct phone_number, state
from camp.DPI_ACCESS_LINES_IN_SERVICE
where rpt_mnth_year = '202306'
and state in ('AZ','CA','ID','IL','IN','MI','NC','NV','OH','OR','SC','WA','WI','TX','FL')
and (service_and_equipment like '%69328%'
or service_and_equipment like '%69329%'
or service_and_equipment like '%69330%'
or service_and_equipment like '%69333%'
or service_and_equipment like '%69334%'
or service_and_equipment like '%69552%'
or service_and_equipment like '%6955B%'  -- added Aug-2014  
or service_and_equipment like '%6955C%'  -- added Aug-2014 
or service_and_equipment like '%6932P%'
or service_and_equipment like '%6942P%'
or service_and_equipment like '%89187%'
or service_and_equipment like '%89188%'
or service_and_equipment like '%UNPPU%'
or service_and_equipment like '%PLATU%')
and ccna is not null
)
group by state 
--
UNION ALL
--  WV UNE Platform   
select state, count(*) 
from (
select distinct phone_number, state
from camp.DPI_ACCESS_LINES_IN_SERVICE
where rpt_mnth_year = '202306'
and state in ('WV')
and (service_and_equipment like '%PTLP%'
or service_and_equipment like '%PTBL%'
or service_and_equipment like '%PTUUP%'
or service_and_equipment like '%PTUPL%'
or service_and_equipment like '%UNPT1%'
or service_and_equipment like '%UNPT2%'
or service_and_equipment like '%PTXL1%'
or service_and_equipment like '%PTX91%'
or service_and_equipment like '%I2265%'
or service_and_equipment like '%UNPI1%'
or service_and_equipment like '%PTPP1%'
or service_and_equipment like '%UNPP1%'
or service_and_equipment like '%UNPA1%'
or service_and_equipment like '%UNCP1%')
and ccna is not null
)
group by state 
order by 1;


