-- Tab delimited   save as SPR_GB_MMDDYY.txt    (SPR_GB_123110.txt)     

select clli_report, state, why_miss, order_no, ecckt,
  due_sched_date, efctv_cmpln_date
from ossams_mart.tb_dm_ossams_prvsn_fact
--where trunc(load_date, 'dd') = TRUNC(SYSDATE, 'dd')-1
where to_char(load_date,'YYYYMM') = '201112'
  and state in ('CA', 'OR', 'WA', 'ID', 'NV', 'AZ', 'OH','WI', 'IL') -- 'MI','IN', 'SC', 'NC')
  and service_code in ('CA', 'CL', 'CN', 'D1', 'DI', 'DK',
  'DO', 'IP', 'LD', 'MA', 'PC', 'TA', 'TG', 'TK', 'TL')
  and z_action not in ('D', 'O', 'K', 'M', 'R')
  and ccna in ('CUST')
  and invalid_ind not in ('I')
  
