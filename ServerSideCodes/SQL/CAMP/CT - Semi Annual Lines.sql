--FROM CPODSPRD

--******** This pulls the total volume of UNEs for the Year End reporting *********

--
select service_addr_state, 'UNE' prod, count(distinct camp_circuit_id)
from (
select line_id, class_of_service, wholesale_ccna_acna, camp_circuit_id, service_addr_state
from camp.ods_access_lines_in_service
where service_addr_state = 'CT'
and wholesale_ccna_acna is not null
and rpt_month_year = '062023'
and class_of_service in ('FTR32zz','FTR33xx','FTR35xx','UBN','FTR31')
)
group by service_addr_state
--
UNION ALL
--******** This pulls the total volume of WSA for the Year End reporting *********
--
select service_addr_state, 'WSA' prod, count(distinct line_id)
from (
select line_id, class_of_service, wholesale_ccna_acna, camp_circuit_id, service_addr_state
from camp.ods_access_lines_in_service
where service_addr_state = 'CT'
and wholesale_ccna_acna is not null
and rpt_month_year = '062023'
and class_of_service in ('U5RBX','U5RB1','U5RB2','U5RB3','U5RB4','U5RRX','U5RR1','U5RR2','U5RR3')
)
group by service_addr_state
--
UNION ALL
--******** This pulls the total volume of Resale POTs for the Year End reporting *********
--
select service_addr_state, 'Resale' prod, count(distinct line_id)
from (
select line_id, class_of_service, wholesale_ccna_acna, camp_circuit_id, service_addr_state
from camp.ods_access_lines_in_service
where service_addr_state = 'CT'
and wholesale_ccna_acna is not null
and rpt_month_year = '062023'
and class_of_service in ('FTR18','FTR19')
)
group by service_addr_state
--
UNION ALL
--
select service_addr_state state, 'Resale+' prod, count(*) 
from camp.ODS_ACCESS_LINES_IN_SERVICE OA, camp.VW_USOC_PRODUCT VPU
  WHERE OA.CLASS_OF_SERVICE = VPU.USOC
and service_addr_state = 'IL'
and UPPER (ASSET_STATUS) = 'ACTIVE'
    AND NOT (UPPER (NVL (OA.CUSTOMER_ACCOUNT_TYPE, 0)) = 'COMPANY'
    AND UPPER (NVL (OA.CUSTOMER_ACCOUNT_SUB_TYPE, 0)) in ('INTERNAL', 'COIN PUBLIC'))
	and rpt_month_year = '062023'
	and wholesale_ccna_acna is not null
	and product_group in ('2100_W')
group by service_addr_state
--
UNION ALL
--
select service_addr_state state, 'Resale+' prod, count(*) 
from camp.ODS_ACCESS_LINES_IN_SERVICE OA, camp.VW_USOC_PRODUCT VPU
  WHERE OA.CLASS_OF_SERVICE = VPU.USOC
and service_addr_state = 'IL'
and UPPER (ASSET_STATUS) = 'ACTIVE'
    AND NOT (UPPER (NVL (OA.CUSTOMER_ACCOUNT_TYPE, 0)) = 'COMPANY'
    AND UPPER (NVL (OA.CUSTOMER_ACCOUNT_SUB_TYPE, 0)) in ('INTERNAL', 'COIN PUBLIC'))
	and rpt_month_year = '062023'
	and wholesale_ccna_acna is not null
	and product_group in ('2200_W')
	and class_of_service = 'FTR220x'
	and wholesale_ccna_acna <> '100'
group by service_addr_state
--
UNION ALL
--
select service_addr_state state, 'UNE' prod, count(*) 
from camp.ODS_ACCESS_LINES_IN_SERVICE OA, camp.VW_USOC_PRODUCT VPU
  WHERE OA.CLASS_OF_SERVICE = VPU.USOC
and service_addr_state = 'IL'
and UPPER (ASSET_STATUS) = 'ACTIVE'
    AND NOT (UPPER (NVL (OA.CUSTOMER_ACCOUNT_TYPE, 0)) = 'COMPANY'
    AND UPPER (NVL (OA.CUSTOMER_ACCOUNT_SUB_TYPE, 0)) in ('INTERNAL', 'COIN PUBLIC'))
	and rpt_month_year = '062023'
	and wholesale_ccna_acna is not null
	and product_group in ('3220_W','3555_W','3344_W')
group by service_addr_state
order by 1; 
