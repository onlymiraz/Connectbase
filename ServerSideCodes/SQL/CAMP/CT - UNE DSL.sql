*********This will count just DSL in CT************

select distinct phone_number, class_of_service, service_and_equipment se, ccna, circuit
from camp.dpi_access_lines_in_service
where state = 'CT'
and rpt_mnth_year = '201412'
and (service_and_equipment like '%1GB%'
or service_and_equipment like '%1GR%'
or service_and_equipment like '%3EPU5%'
or service_and_equipment like '%3EPU6%'
or service_and_equipment like '%3EPUC%'
or service_and_equipment like '%3EPUQ%'
or service_and_equipment like '%IEPUC%'
or service_and_equipment like '%IEPUQ%'
or service_and_equipment like '%IR9UB%'
or service_and_equipment like '%IR9UC%'
or service_and_equipment like '%IRBT5%'
or service_and_equipment like '%IRBT6%'
or service_and_equipment like '%NR9UD%'
or service_and_equipment like '%NRBXV%'
or service_and_equipment like '%NRMNA%'
or service_and_equipment like '%SLY%'
or service_and_equipment like '%SLZ%'
or service_and_equipment like '%UA5AX%'
or service_and_equipment like '%UA5BX%'
or service_and_equipment like '%ULPEX%'
or service_and_equipment like '%ULPPX%'
or service_and_equipment like '%ULPQX%'
or service_and_equipment like '%UY2Q1%'
or service_and_equipment like '%UY2Q2%'
or service_and_equipment like '%UY2Q1%'
or service_and_equipment like '%UY2Q2%'
or service_and_equipment like '%UY2QX%'
or service_and_equipment like '%UY2RX%')







