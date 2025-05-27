
--In ODS server   

OLD METHOD!!!!!!
SELECT document_number, create_date, desired_due_date_last, trunc(order_complete) order_complete, linecount, customer_account_type
FROM camp.VW_PR_4_05_3540_F13 
WHERE (SERVICE_REQUEST_STATUS >= 801 
AND DISPATCH_COMPLETE IS NULL
AND TO_CHAR(BILLING_COMPLETE, 'MMYYYY')='092012')
and dw_state='MI'
and DW_COMPANY <> '100' ;


--USE THIS ONE    
select pon, ccna, document_number, create_date, desired_due_date_last, trunc(order_complete) order_complete, linecount, customer_account_type
FROM camp.ods_service_orders
where dw_state = 'MI'  --and ccna <> '100'
and task_type in ('PO','CT')
and to_char(order_complete,'yyyymm') = '202312';
