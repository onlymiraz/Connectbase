select * from camp.num_den_query
where sub_metrics_no = 'MR-2-01-3562'
and state_code = 'OR'

SELECT * --sum(TOTAL_LINES_IN_SERVICE) 
FROM camp.VW_MR_2_01_DEN_F13 WHERE (( (product_group = '2210_R' and dw_company = '100') 
  OR (product_group = '3200_W' and nvl(dw_company,0) <> '100' 
  --AND Jurisdiction_Code in (4,5)      
AND((((nc NOT LIKE 'L%' and nc NOT LIKE 'X%') OR nc like 'LX%')
      AND (nc NOT LIKE 'HC%' OR SUBSTR (line_id, 4, 4) = 'HCFU')
      AND (nc NOT LIKE 'HF%' OR SUBSTR (line_id, 4, 4) = 'HFFU')
      AND (nc NOT LIKE 'LY%' OR SUBSTR (line_id, 4, 4) IN ('LYFU', 'LYGU'))
      and NC not LIKE 'O%'
      and NC not LIKE 'K%'
      and NC not LIKE 'V%')or nc is null)
      AND nci || secnci IN (SELECT DISTINCT nci || secnci FROM camp.ods_nc_nci_secnci_data WHERE c2c_prod_desc IN ('UNE TRANSPORT DS0'))
      AND SUBSTR (line_id, 4, 4) IN ('LXFU', 'LGFU', 'LYFU', 'LYGU')  )))and DW_COMPANY <>'100' and dw_state='OR' and  DW_RPT_MON_YEAR ='082012'
	  
	  
select PRODUCT_NAME,	LINE_ID,	CLASS_OF_SERVICE,	WHOLESALE_CCNA_ACNA,	RPT_MONTH_YEAR,	CAMP_CIRCUIT_ID, NC,	JURISDICTION_CODE,	NCI,	SECNCI, src_sys,
case when wholesale_ccna_acna = '100' then 'ILEC'
     when wholesale_ccna_acna is null then 'ILEC' else 'CLEC' end CLEC_ILEC
FROM camp.ODS_ACCESS_LINES_IN_SERVICE OA --, camp.VW_USOC_PRODUCT VPU
--  WHERE OA.CLASS_OF_SERVICE = VPU.USOC	  
where service_addr_state = 'OR'
--and class_of_service in ('UBN','FTR31') 
and rpt_month_year = '082012'
--and wholesale_ccna_acna is not null
--and wholesale_ccna_acna <> '100'
order by line_id, class_of_service


and substr(camp_circuit_id,3,1) = 'L'
and substr(camp_circuit_id,6,1) = 'U'


select * from camp.VW_USOC_PRODUCT 
where usoc = 'XDV2X'
order by 1

select * from camp.VW_MR_2_01_DEN_F13
where line_id = '85/LXFU/500683/   /GTEW/   '



select *
FROM camp.ODS_ACCESS_LINES_IN_SERVICE
where camp_circuit_id = '02IBAD5035960373'