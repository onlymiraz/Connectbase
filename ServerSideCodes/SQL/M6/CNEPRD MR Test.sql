select ticket_id, ckt_id, circuit, acna, 
       create_date, cleared_dt, closed_dt, ttr, total_duration, repair_code,
       icsc, priloc_state, priloc, actl, mux, acna1, acna2, ccna1, ccna2
from (
---------------------------------------------------------------------------------
select a.c1 ticket_id,
       a.C800011120 ckt_id, 
       replace(replace(a.C800011120,' '),'/') circuit,
       trim(a.C536870980) acna, 
       to_date('01-JAN-1970','dd-mon-yyyy')+(a.C777031010/60/60/24) CREATE_DATE,
       to_date('01-JAN-1970','dd-mon-yyyy')+(a.C777010106/60/60/24) CLEARED_DT,
       to_date('01-JAN-1970','dd-mon-yyyy')+(a.c536871065/60/60/24) CLOSED_DT,
       round(a.C700870918/3600,2) ttr,
       round(a.C777010028/3600,2) Total_Duration,
       C800006026 repair_code
from whsl_adv_hist.rmdy_t1074 a  
where a.C800023051 = 'closed'
 and a.C777031408 in ('CNOC','Commercial-CTF')
 and c1 = 'OP-000002255080'
) trbl
--------------------------------------------------------------------------------
JOIN (
 SELECT * FROM (
    SELECT DISTINCT 
      upper(ec_company_code) icsc, 
      substr(primary_location,5,2) priloc_state,
      substr(primary_location,1,6) priloc,
      substr(access_cust_terminal_location,1,6) actl,
      substr(mux_location,1,6) mux,
      trim(acna) acna1, 
      trim(ccna) ccna1,
      trim(acna) acna2, 
      trim(ccna) ccna2, 
      ECCKT,
      ROW_NUMBER() OVER (PARTITION BY ECCKT ORDER BY STG_IDENT DESC) AS RNUM
  FROM whsl_adv_hist.m6_design_layout_report_thist
    ) WHERE RNUM = 1 
    ) DLR ON TRBL.CKT_ID = DLR.ECCKT 
    
    
    
;
