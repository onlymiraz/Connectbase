select product_group, count(*)			
 from (
 select distinct line_id, rpt_month_year, product_group
  FROM camp.ods_access_lines_in_service oa, camp.vw_usoc_product vpu
 where oa.class_of_service = vpu.usoc
 and UPPER (asset_status) = 'ACTIVE'
 AND rpt_month_year IN ('012013','022013','032013')	
 and service_addr_state = 'IL'	
 and vpu.product_group in ('2100_W','2200_W','3555_W')
 and wholesale_ccna_acna is not null
 and wholesale_ccna_acna <> '100'
 )
 group by product_group