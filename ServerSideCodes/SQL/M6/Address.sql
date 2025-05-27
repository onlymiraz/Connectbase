



select document_number, SECLOC_END_USER_STREET_ADDRESS SA, SECLOC_CITY CITY, SECLOC_STATE STATE, max(last_modified_date)
from casdw.design_layout_report
where document_number in (
'1287048',
'1294374')
group by document_number, SECLOC_END_USER_STREET_ADDRESS, SECLOC_CITY, SECLOC_STATE
order by 1




