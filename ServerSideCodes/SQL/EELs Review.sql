select *
from camp.num_den_query
where sub_metrics_no like 'PR-4-01-3575'



SELECT count(DISTINCT DOCUMENT_NUMBER) DEN 
FROM VW_PR_4_01_3575_F13 WHERE (ACTIVITY_IND in ('N', 'C')
AND SERVICE_REQUEST_STATUS >= 801 AND NVL(PSC_CODE, '0') != 'X'
AND DISPATCH_COMPLETE IS NULL
AND TO_CHAR(BILLING_COMPLETE, 'MMYYYY') ='032012')and DW_COMPANY <>'100' and dw_state='OR'



select * --distinct document_number, ccna, pon, exchange_carrier_circuit_id, dw_state, dw_product_id, nc, secnci, service_and_product_enhanc_cod
FROM camp.ods_service_orders osos --, camp.vw_usoc_product vup
--where osos.dw_product_id = vup.usoc
--and document_number = '1295939'
--and dw_product_id = 'XDH1X-UNE2'
where exchange_carrier_circuit_id like '%FU%'
and dw_state not in ('WV','NY')
and to_char(order_complete,'yyyy') = '2012'


--and dw_state = 'OR'
--and dw_company <> '100'
--and exchange_carrier_circuit_id like '%HCFU%'
--and to_char(order_complete,'yyyymm') = '201207' 
and document_number = '1295939'



, vw_usoc_product vup
WHERE osos.dw_product_id = vup.usoc

select * from camp.vw_usoc_product
where usoc = 'XDH1X-UNE2'
order by 1



where product_group = '3575_W'


AND ( (VOSOP.PRODUCT_GROUP = '2211_R' AND DW_COMPANY = '100')
             OR (VOSOP.PRODUCT_GROUP = '3575_W' AND NVL (DW_COMPANY, 0) <> '100'
AND((((nc NOT LIKE 'L%' and nc NOT LIKE 'X%') OR nc like 'LX%')
AND (NC not LIKE 'HC%'or SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID, 4, 4) = 'HCFU')
      and (NC not LIKE 'HF%'or SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID, 4, 4) = 'HFFU')
      AND (NC not LIKE 'LY%' or SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID, 4, 4) in ('LYFU','LYGU') )
      and NC not LIKE 'O%'
      and NC not LIKE 'K%'
      and NC not LIKE 'V%')or nc is null)
                AND NCI || SECNCI IN (SELECT DISTINCT NCI || SECNCI FROM ODS_NC_NCI_SECNCI_DATA WHERE C2C_PROD_DESC = 'UNE EELS DS1')
                AND SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID, 4, 4) IN ('HCFU', 'HCGU') 
                )
           )
		   
		   
		   
		   select * from camp.vw_usoc_product vup
		   where product_group = '3604_W'
		   
		   where usoc like 'XDH%X-UNE%'
		   
		   
		   
		   
SELECT count(DISTINCT DOCUMENT_NUMBER) DEN 
FROM VW_PR_4_02_3604_F13 WHERE ( ACTIVITY_IND IN ('N', 'C') AND SERVICE_REQUEST_STATUS < 801 AND NVL(PSC_CODE, '0') != 'X'
AND TO_CHAR(DESIRED_DUE_DATE_LAST, 'YYYYMM') <='201203')and DW_COMPANY <>'100' and dw_state='WA'



FROM VW_ODS_SERVICE_ORDERS_P VOSOP
WHERE NVL (SUPPLEMENT, '0') <> '1'
       AND NVL (ACTIVITY_IND, '0') <> 'D'
       AND (UPPER (NVL (PROJECT_NAME, 0)) NOT LIKE 'ADMINISTRATION' OR NVL (PROJECT_NAME, '-') LIKE '%-%')
       AND ((PRODUCT_GROUP = '2211_R' AND DW_COMPANY = '100')
            OR (PRODUCT_GROUP = '3604_W' AND NVL (DW_COMPANY, 0) <> '100'
AND((((nc NOT LIKE 'L%' and nc NOT LIKE 'X%') OR nc like 'LX%')
AND (NC not LIKE 'HC%'or SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID, 4, 4) = 'HCFU')
      and (NC not LIKE 'HF%'or SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID, 4, 4) = 'HFFU')
      AND (NC not LIKE 'LY%' or SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID, 4, 4) in ('LYFU','LYGU') )
      and NC not LIKE 'O%'
      and NC not LIKE 'K%'
      and NC not LIKE 'V%')or nc is null)
               AND NCI || SECNCI IN (SELECT DISTINCT NCI || SECNCI FROM ODS_NC_NCI_SECNCI_DATA WHERE C2C_PROD_DESC = 'UNE TRANSPORT DS1')
               AND SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID, 4, 4) IN ('HCFU', 'HCGU') 
               )
           )
);



select * from camp.vw_ods_service_orders_p
where product_group = '3604_W'



select * --distinct document_number, ccna, pon, exchange_carrier_circuit_id, dw_state, dw_product_id, nc, secnci, service_and_product_enhanc_cod
FROM camp.ods_service_orders osos 
where service_and_product_enhanc_cod in ('UNB1OT','UNBALL')
and substr(exchange_carrier_circuit_id,4,4) not in ('HCFU','HFFU')
and dw_state not in ('WV','NY')
and to_char(order_complete,'yyyy') = '2012'