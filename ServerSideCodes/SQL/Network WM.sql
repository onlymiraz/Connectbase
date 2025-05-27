-- Tab delimited   save as SPR_WM_MMDDYY.txt    (SPR_WM_123110.txt) 

select  a.clli_report, d.state, why_miss, order_no, ecckt, due_sched_date,
        efctv_cmpln_date
from ossams_mart.tb_dm_ossams_prvsn_fact a, ossams_mart.tb_sa_ossams_service_code_lkp b,
ossams_mart.tb_ossams_clli8_lkp c, ossams_mart.tb_ossams_clli11_lkp d
where a.clli_report=c.clli8
  and c.clli11 = d.clli11
  and b.service_type in ('8')
  and b.st_category in ('Z')
  and a.service_code=b.service_code
  --and trunc(a.load_date, 'dd') = TRUNC(SYSDATE, 'dd')-1
  and to_char(a.load_date,'YYYYMM') = '201112'
  and d.state in ('CA', 'OR', 'WA', 'ID', 'NV', 'AZ', 'IL', 'OH', 'WI') -- 'MI', 'IN','SC', 'NC')
  and a.z_action not in ('D', 'K', 'M', 'O', 'R')
  and a.invalid_ind not in ('I')
  and a.tra is NULL
AND NOT (a.service_code='M8' and (substr(a.ecckt,2,2)='T1'
  or substr(a.ecckt,2,2)='T3' or substr(a.ecckt,3,2)='T1'
  or substr(a.ecckt,3,2)='T3' or substr(a.ecckt,4,2)='T1'
  or substr(a.ecckt,4,2)='T3' or substr(a.ecckt,5,2)='T1'
  or substr(a.ecckt,5,2)='T3' or substr(a.ecckt,6,2)='T1'
  or substr(a.ecckt,6,2)='T3' or substr(a.ecckt,7,2)='T1'
  or substr(a.ecckt,7,2)='T3' or substr(a.ecckt,2,3)='OC3'
  or substr(a.ecckt,3,3)='OC3' or substr(a.ecckt,4,3)='OC3' 
  or substr(a.ecckt,5,3)='OC3' or substr(a.ecckt,6,3)='OC3'
  or substr(a.ecckt,7,3)='OC3' or substr(a.ecckt,2,3)='T04'
  or substr(a.ecckt,3,3)='T04' or substr(a.ecckt,4,3)='T04'
  or substr(a.ecckt,5,3)='T04' or substr(a.ecckt,6,3)='T04'
  or substr(a.ecckt,7,3)='T04' or substr(a.ecckt,2,4)='OC03'
  or substr(a.ecckt,2,4)='OC12' or substr(a.ecckt,2,4)='OC24'
  or substr(a.ecckt,2,4)='OC48' or substr(a.ecckt,2,5)='OC192'
  or substr(a.ecckt,3,4)='OC03' or substr(a.ecckt,3,4)='OC12'
  or substr(a.ecckt,3,4)='OC24' or substr(a.ecckt,3,4)='OC48'
  or substr(a.ecckt,3,5)='OC192' or substr(a.ecckt,4,4)='OC03'
  or substr(a.ecckt,4,4)='OC12' or substr(a.ecckt,4,4)='OC24'
  or substr(a.ecckt,4,4)='OC48' or substr(a.ecckt,4,5)='OC192'
  or substr(a.ecckt,5,4)='OC03' or substr(a.ecckt,5,4)='OC12'
  or substr(a.ecckt,5,4)='OC24' or substr(a.ecckt,5,4)='OC48'
  or substr(a.ecckt,5,5)='OC192' or substr(a.ecckt,6,4)='OC03'
  or substr(a.ecckt,6,4)='OC12' or substr(a.ecckt,6,4)='OC24'
  or substr(a.ecckt,6,4)='OC48' or substr(a.ecckt,6,5)='OC192'
  or substr(a.ecckt,7,4)='OC03' or substr(a.ecckt,7,4)='OC12'
  or substr(a.ecckt,7,4)='OC24' or substr(a.ecckt,7,4)='OC48'
  or substr(a.ecckt,7,5)='OC192'))