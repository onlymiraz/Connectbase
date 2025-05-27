
--for all CLEC Held Orders 
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_2110_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY <>'100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_2120_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY <>'100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_2200_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY <>'100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL')  
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3221_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY <>'100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3222_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY <>'100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') ;
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3342_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY <>'100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3555_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY <>'100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code
FROM camp.VW_PR_4_02_3563_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY <>'100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3540_F13 WHERE (ACTIVITY_IND IN ('N', 'C','D') 
AND SERVICE_REQUEST_STATUS < 801 
AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804')and DW_COMPANY <>'100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
;








--for all ILEC Held Orders 
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_2110_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY = '100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_2120_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY = '100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_2200_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY = '100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3221_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY = '100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3222_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY = '100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3342_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY = '100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3555_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY = '100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3563_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804') and DW_COMPANY = '100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
UNION ALL
SELECT product_group, document_number, dw_state, dw_company, pon, project_Name, create_date, desired_due_date_last, request_type, dw_rpt_mon_year, source_system, jeopardy_type_cd, jeopardy_reason_code 
FROM camp.VW_PR_4_02_3540_F13 WHERE (ACTIVITY_IND IN ('N', 'C','D') 
AND SERVICE_REQUEST_STATUS < 801 
AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201804')and DW_COMPANY = '100' and dw_state in ('IN','OR','OH','WA','NC') --'CA','FL') 
--and dw_rpt_mon_year not in ('112013')
;





