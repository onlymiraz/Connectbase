

SELECT ticket_id, ckt_id, circuit, ckt_design_id, location_name,
       case when site_state is not null then site_state
            else rem_state end state,
       case when clec_id is not null then clec_id 
            else vlacna end clec_id,     
       assignmentprofile, request_type,
       create_date, 
       case when cleared_date is null then closed_date else cleared_date end cleared_date, 
       case when closed_date is null then cleared_date else closed_date end closed_date, 
       repair_code, disp, cause_code, 
       case when disp = 'NTF' then 0 else ttr end ttr    -- Per Matt Freeman on 1/30/2017            
FROM (
----
select a.*, VLAN.ACNA VLACNA, TFR.disp 
       --TFR1.trbl_found_number, TFR1.trbl_found_desc, TFR1.disp, RC.trbl_found_number trbl_found_number2, RC.trbl_found_desc trbl_found_desc2, RC.disp disp2, TFR2.disp disp3  
from (
----
select a.fld_requestid ticket_id,
       substr(a.fld_siteid,1,6) site_clli6,
       substr(a.fld_siteid,5,2) site_state,
       substr(a.zloc_clli,5,2) z_state,
       a.fld_customeraddressstate rem_state,
       a.fld_state rem_state2,
       a.exchange_carrier_circuit_id ckt_id, 
       a.fld_circuit_design__id ckt_design_id,
       replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
       case when service_type_code = 'HC' then 'DS1'
            when service_type_code = 'HF' then 'DS3'
            when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,4,5) like '%T1%' then 'DS1'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,4,5) like '%T3%' then 'DS3'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,1,4) like '%HC%' then 'DS1'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,1,4) like '%HF%' then 'DS3'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,1,2) = 'R2' then 'Ethernet'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,4,2) in ('L1','L2') then 'Ethernet'
            when substr(service_type_code,1,1) in ('X','L') then 'DS0'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,3,1) in ('X','L') then 'DS0'
            when substr(service_type_code,1,2) = 'OC' then 'OCN'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,1,8) like '%OC%' then 'OCN'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,3,2) in ('OB','OD','OF','OG') then 'OCN' 
            when substr(service_type_code,1,2) = 'SX' then 'Ethernet'
            when substr(CIR.EXCHANGE_CARRIER_circuit_ID,3,1) in ('K','V') then 'Ethernet'
            when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
            else ' ' end product,
       case when DLR.CCNA is not null and length(dlr.ccna) = '3' then dlr.ccna
            when a.acna is not null then trim(a.acna)
            when DLR.ACNA is not null and length(dlr.acna) = '3' then dlr.acna
            else fld_vfouserid end clec_id, 
       trim(a.acna) acna,
       DLR.ACNA DLR_ACNA,
       DLR.CCNA DLR_CCNA,
       REGEXP_REPLACE (a.fld_alocationaccessname2,'[[:cntrl:]]*') location_name,
       a.fld_vfouserid,
       a.fld_rate_code_category,
       a.fld_requesttype request_type, 
       to_date('01-JAN-1970','dd-mon-yyyy')+(a.fld_startdate/60/60/24) create_date,
       to_date('01-JAN-1970','dd-mon-yyyy')+(a.fld_event_end_time/60/60/24) cleared_date,
       to_date('01-JAN-1970','dd-mon-yyyy')+(a.dte_closeddatetime/60/60/24) closed_date,
       round(a.fld_mttrepair/3600,2) ttr,
       round(a.h_fld_totalopentime_secs_/3600,2) Total_Duration,
       fld_complete_repaircode repair_code,
       fld_complete_causecode cause_code,
       fld_troublefoundint trbl_found_cd,
       a.fld_requeststatus reqstat,
       trim(a.fld_assignmentprofile) assignmentprofile,
       a.fld_troublereportstate,
       to_date('01-JAN-1970','dd-mon-yyyy')+(a.fld_modifieddate/60/60/24) fld_modifieddate             
from whsl_adv_hist.os3_op_request a, 
     (SELECT DISTINCT * FROM
      (SELECT CIRCUIT_DESIGN_ID, ISSUE_NBR, ISSUE_STATUS, ACNA, CCNA, STG_IDENT, 
       ROW_NUMBER() OVER (PARTITION BY CIRCUIT_DESIGN_ID ORDER BY STG_IDENT asc) R 
        FROM whsl_adv_hist.m6_design_layout_report_thist
         WHERE (acna is not null or ccna is not null)
         )
          WHERE R = 1) DLR,
     (SELECT DISTINCT * FROM
      (SELECT CIRCUIT_DESIGN_ID, EXCHANGE_CARRIER_CIRCUIT_ID, TYPE, STATUS, SERVICE_TYPE_CODE, NETWORK_CHANNEL_SERVICE_CODE, RATE_CODE, STG_IDENT, 
       ROW_NUMBER() OVER (PARTITION BY CIRCUIT_DESIGN_ID ORDER BY STG_IDENT desc) R 
        FROM whsl_adv_hist.m6_circuit_thist)
         WHERE R = 1) CIR            
where A.fld_circuit_design__id = DLR.CIRCUIT_DESIGN_ID (+)
  and a.fld_circuit_design__id = cir.circuit_design_id (+)
  AND (to_char(to_date('01-JAN-1970','dd-mon-yyyy')+(dte_closeddatetime/60/60/24),'yyyymm') in ('202202')
   or (dte_closeddatetime is null and(to_char(to_date('01-JAN-1970','dd-mon-yyyy')+(fld_event_end_time/60/60/24),'yyyymm') in ('202202'))))
  --and fld_requesttype in ('Agent','Alarm','Customer','Maintenance')
  and fld_assignmentprofile in ('CNOC','Commercial-CTF')
  and fld_troublereportstate = 'closed'
  --and fld_requestid = 'OP-000003086355'
  AND (CIR.TYPE <> 'T' or CIR.type is null)
----
) 
A,
(select CIR.circuit_design_id, CIR.ckt_id, SR.ACNA, SR.CCNA
  from 
    (SELECT DISTINCT * FROM
      (SELECT CIRCUIT_DESIGN_ID, EXCHANGE_CARRIER_CIRCUIT_ID ckt_id,  STATUS, STG_IDENT, 
       ROW_NUMBER() OVER (PARTITION BY CIRCUIT_DESIGN_ID ORDER BY STG_IDENT desc) R 
        FROM whsl_adv_hist.m6_circuit_thist
        where substr(service_type_code,1,2) = 'VL') 
         WHERE R = 1) CIR,
    (SELECT DISTINCT * FROM
      (SELECT CKT_IDENT, DESIGN_ORD_SUM_ID, STG_IDENT,
       ROW_NUMBER() OVER (PARTITION BY CKT_IDENT ORDER BY STG_IDENT desc) R 
       FROM WHSL_ADV_HIST.M6_DESIGN_THIST)
       WHERE R = 1) D,
    (SELECT DISTINCT * FROM
      (SELECT DESIGN_ORD_SUM_ID, DOCUMENT_NUMBER, STG_IDENT,
       ROW_NUMBER() OVER (PARTITION BY DESIGN_ORD_SUM_ID ORDER BY STG_IDENT desc) R 
       FROM WHSL_ADV_HIST.M6_DESIGN_ORD_SUMM_THIST)
       WHERE R = 1) DOS, 
    (SELECT DISTINCT * FROM
      (SELECT DOCUMENT_NUMBER, ACNA, CCNA, STG_IDENT,
       ROW_NUMBER() OVER (PARTITION BY DOCUMENT_NUMBER ORDER BY STG_IDENT desc) R 
       FROM WHSL_ADV_HIST.M6_SERV_REQ_THIST
       WHERE (SUPPLEMENT_TYPE <> 1 OR SUPPLEMENT_TYPE IS NULL))
       WHERE R = 1) SR  
   WHERE CIR.CKT_id = d.ckt_ident 
    and d.design_ord_sum_id =  dos.design_ord_sum_id
    and dos.document_number =  sr.document_number) VLAN,  
 CARRIER_USER_TABLES.TRBL_FOUND_REMEDY TFR
-- CARRIER_USER_TABLES.REPAIR_CODE RC,
-- CARRIER_USER_TABLES.TRBL_FOUND_REMEDY TFR2     
where A.CKT_DESIGN_ID = VLAN.CIRCUIT_DESIGN_ID (+)
 -- and A.trbl_found_cd = TFR1.trbl_found_number (+)
--and A.repair_code = RC.repair_code (+)
and A.repair_code = TFR.trbl_found_desc (+)
AND PRODUCT = 'Ethernet'
----
) 
where (clec_id in ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM')
 OR VLACNA IN ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM'))

;