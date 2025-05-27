select 'Special' Indicator, j.Region_descr src_sys, b.service_type_descr svc_code, e.customer2, a.acna, NULL ccna, 
       a.ecckt ckt, a.prjct_number proj, NULL Add_CLO, a.order_no Add_Ord, a.due_cmpln_date Add_Comp, 
       dis.order_no Dis_Ord, dis.due_cmpln_date Dis_Comp, a.clli_a AddAloc, dis.clli_a DisAloc,
       a.prchs_order_no pon
from ossams_mart.tb_dm_ossams_prvsn_fact a, ossams_mart.tb_ossams_service_type_lkp b,
     ossams_mart.tb_dm_ossams_acna_lkp e, ossams_mart.tb_ossams_district_lkp f,
     ossams_mart.tb_ossams_division_lkp g, ossams_mart.tb_ossams_clli8_lkp h,
     ossams_mart.tb_ossams_clli11_lkp i, ossams_mart.tb_ossams_region_lkp j,  
(
            select  c.*, d.*
            from ossams_mart.tb_dm_ossams_prvsn_fact c, ossams_mart.tb_ossams_service_type_lkp d
            where to_char(c.due_cmpln_date, 'yyyy') = to_char(sysdate, 'yyyy') 
              and to_char(c.due_cmpln_date, 'mm') = (to_char(sysdate, 'mm')-1)
              and c.service_code = d.service_code
              and d.st_category IN ('V','Z')
              and d.service_type_descr IN ('DS1','DS3','OCN')
              and d.st_category = 'Z'
              and c.z_action IN ('O')) dis
where to_char(a.due_cmpln_date, 'yyyy') = to_char(sysdate, 'yyyy') 
  and to_char(a.due_cmpln_date, 'mm') = (to_char(sysdate, 'mm')-1)
  and a.service_code = b.service_code(+)
  and a.acna = e.acna(+)
  and a.clli_report = h.clli8
  and h.clli11 = i.clli11
  and g.region_uid = j.region_uid
  and i.district_uid = f.district_uid 
  and f.division_uid = g.division_uid
  and b.st_category IN ('V','Z')
  and b.service_type_descr IN ('DS1','DS3','OCN')
  and b.st_category = 'V'
  and a.z_action IN ('I')
  and a.ecckt = dis.ecckt
  and a.clli_a <> dis.clli_a
UNION ALL
select 'Switched' Indicator, j.Region_descr src_sys, b.service_type_descr svc_code, e.customer2, a.acna, NULL ccna, 
       a.ecckt ckt, a.prjct_number proj, NULL Add_CLO, a.order_no Add_Ord, a.due_cmpln_date Add_Comp, 
       dis.order_no Dis_Ord, dis.due_cmpln_date Dis_Comp, a.clli_a AddAloc, dis.clli_a DisAloc,
       a.prchs_order_no pon
from ossams_mart.tb_dm_ossams_prvsn_fact a, ossams_mart.tb_ossams_service_type_lkp b,
     ossams_mart.tb_dm_ossams_acna_lkp e, ossams_mart.tb_ossams_district_lkp f,
     ossams_mart.tb_ossams_division_lkp g, ossams_mart.tb_ossams_clli8_lkp h,
     ossams_mart.tb_ossams_clli11_lkp i, ossams_mart.tb_ossams_region_lkp j,    
(
            select  c.*, d.*
            from ossams_mart.tb_dm_ossams_prvsn_fact c, ossams_mart.tb_ossams_service_type_lkp d
            where to_char(c.due_cmpln_date, 'yyyy') = to_char(sysdate, 'yyyy') 
              and to_char(c.due_cmpln_date, 'mm') = (to_char(sysdate, 'mm')-1)
              and c.service_code = d.service_code
              and d.st_category IN ('V','Z')
              and c.service_code = 'M8'
              and d.st_category = 'Z'
              and c.z_action IN ('O')) dis
where to_char(a.due_cmpln_date, 'yyyy') = to_char(sysdate, 'yyyy') 
  and to_char(a.due_cmpln_date, 'mm') = (to_char(sysdate, 'mm')-1)
  and a.service_code = b.service_code(+)
  and a.acna = e.acna(+)
  and a.clli_report = h.clli8
  and h.clli11 = i.clli11
  and g.region_uid = j.region_uid
  and i.district_uid = f.district_uid 
  and f.division_uid = g.division_uid
  and b.st_category IN ('V','Z')
  and a.service_code = 'M8'
  and b.st_category = 'V'
  and a.z_action IN ('I')
  and a.ecckt = dis.ecckt
  and a.clli_a <> dis.clli_a