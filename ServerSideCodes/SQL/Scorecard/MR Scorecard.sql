
select region, metric, sum(num) num, sum(den) den, round(sum(num)/sum(den),3) res
from (
select case when a.state in ('WA','CA','OR') then 'West'
	     when a.state in ('IL','OH') then 'Central'
		 else 'National' end region, 
       case when service_type_descr = 'DS0' then 'DS0'
	        when service_type_descr = 'DS1' then 'DS1'
			when service_type_descr = 'DS3' then 'DS3'
			when service_type_descr like 'MSG%' and carrier_type = 'T1' then 'DS1' 
			when service_type_descr like 'MSG%' and carrier_type = 'T3' then 'DS3'
		  else 'OCN' end service,
			round(total_dur_int_time/60,2) num,
	        'MTTR' metric, repair_uid,
			count(*) den
from ossams_mart.tb_dm_ossams_repair_fact a,
     ossams_mart.tb_sa_ossams_service_code_lkp b,
     ossams_mart.tb_ossams_tas_code_lkp c,
     ossams_mart.tb_ossams_service_type e
where to_char(a.load_date, 'yyyymmdd') between '20120219' and '20120225'
  and a.state in ('OR', 'WA', 'ID', 'NV', 'AZ', 'CA', 'OH', 'WI', 'IL')
  and a.report_source in ('1', '2', '3')
  and a.report_type in ('1', '2', '3', '4', '6')
  and a.dspsn in ('4', '6', '7', '9', '10', '11', '12','13','15')
  and a.invalid_ind not in ('I')
  and substr(a.modifier,2,1)not in ('U')
  and a.state = c.state
  and a.cntrl_offce = c.cntrl_offce
  and b.service_type in ('D7', 'A6', 'D6', 'S1')
  and b.st_category in ('Z')
  and a.service_code = b.service_code
  and b.service_type = e.service_type
or to_char(a.load_date, 'yyyymmdd') between '20120219' and '20120225'
  and a.state in ('OR', 'WA', 'ID', 'NV', 'AZ', 'CA', 'OH', 'WI', 'IL')
  and a.report_source in ('1', '2', '3')
  and a.report_type in ('1', '2', '3', '4', '6')
  and a.dspsn in ('4', '6', '7', '9', '10', '11', '12', '13','15')
  and a.invalid_ind not in ('I')
  and substr(a.modifier,2,1)not in ('U')
  and a.state = c.state
  and a.cntrl_offce = c.cntrl_offce
  and b.service_type in ('8')
  and b.st_category in ('Z')
  and a.service_code = b.service_code
  and b.service_type = e.service_type
  and (a.service_code='M8' and substr(a.ckt_id,2,7) LIKE '%T1%'
   or substr(a.ckt_id,2,7) LIKE '%T3%'
   or substr(a.ckt_id,2,7) LIKE '%OC3%'
   or substr(a.ckt_id,2,7) LIKE '%T04%'
   or substr(a.ckt_id,2,7) LIKE '%OC03%'
   or substr(a.ckt_id,2,7) LIKE '%OC12%'
   or substr(a.ckt_id,2,7) LIKE '%OC24%'
   or substr(a.ckt_id,2,7) LIKE '%OC48%'
   or substr(a.ckt_id,2,7) LIKE '%OC192%')
   group by service_type_descr, carrier_type, total_dur_int_time, a.state, repair_uid
 UNION ALL
--TTR NUM   
select case when a.state in ('WA','CA','OR') then 'West'
	     when a.state in ('IL','OH') then 'Central'
		 else 'National' end region, 
       case when service_type_descr = 'DS0' then 'DS0'
	        when service_type_descr = 'DS1' then 'DS1'
			when service_type_descr = 'DS3' then 'DS3'
			when service_type_descr like 'MSG%' and carrier_type = 'T1' then 'DS1' 
			when service_type_descr like 'MSG%' and carrier_type = 'T3' then 'DS3'
		  else 'OCN' end service,
			count(*) num,
		  'TTR' metric, NULL repair_uid, NULL den
from ossams_mart.tb_dm_ossams_repair_fact a,
     ossams_mart.tb_sa_ossams_service_code_lkp b,
     ossams_mart.tb_ossams_tas_code_lkp c,
     ossams_mart.tb_ossams_service_type e
where to_char(a.load_date, 'yyyymmdd') between '20120219' and '20120225'
  and a.state in ('OR', 'WA', 'ID', 'NV', 'AZ', 'CA', 'OH', 'WI', 'IL')
  and a.report_source in ('1', '2', '3')
  and a.report_type in ('1', '2', '3', '4', '6')
  and a.dspsn in ('4', '6', '7', '9', '10', '11', '12','13','15')
  and a.invalid_ind not in ('I')
  and substr(a.modifier,2,1)not in ('U')
  and a.state = c.state
  and a.cntrl_offce = c.cntrl_offce
  and b.service_type in ('D7', 'A6', 'D6', 'S1')
  and b.st_category in ('Z')
  and a.total_dur_int_time <= 240
  and a.service_code = b.service_code
  and b.service_type = e.service_type
or to_char(a.load_date, 'yyyymmdd') between '20120219' and '20120225'
  and a.state in ('OR', 'WA', 'ID', 'NV', 'AZ', 'CA', 'OH', 'WI', 'IL')
  and a.report_source in ('1', '2', '3')
  and a.report_type in ('1', '2', '3', '4', '6')
  and a.dspsn in ('4', '6', '7', '9', '10', '11', '12', '13','15')
  and a.invalid_ind not in ('I')
  and substr(a.modifier,2,1)not in ('U')
  and a.state = c.state
  and a.cntrl_offce = c.cntrl_offce
  and b.service_type in ('8')
  and b.st_category in ('Z')
  and a.total_dur_int_time <= 240
  and a.service_code = b.service_code
  and b.service_type = e.service_type
  and (a.service_code='M8' and substr(a.ckt_id,2,7) LIKE '%T1%'
   or substr(a.ckt_id,2,7) LIKE '%T3%'
   or substr(a.ckt_id,2,7) LIKE '%OC3%'
   or substr(a.ckt_id,2,7) LIKE '%T04%'
   or substr(a.ckt_id,2,7) LIKE '%OC03%'
   or substr(a.ckt_id,2,7) LIKE '%OC12%'
   or substr(a.ckt_id,2,7) LIKE '%OC24%'
   or substr(a.ckt_id,2,7) LIKE '%OC48%'
   or substr(a.ckt_id,2,7) LIKE '%OC192%')
   group by service_type_descr, carrier_type, a.state
UNION ALL
--TTR DEN    
select case when a.state in ('WA','CA','OR') then 'West'
	     when a.state in ('IL','OH') then 'Central'
		 else 'National' end region, 
       case when service_type_descr = 'DS0' then 'DS0'
	        when service_type_descr = 'DS1' then 'DS1'
			when service_type_descr = 'DS3' then 'DS3'
			when service_type_descr like 'MSG%' and carrier_type = 'T1' then 'DS1' 
			when service_type_descr like 'MSG%' and carrier_type = 'T3' then 'DS3'
		  else 'OCN' end service,
			NULL num,
		  'TTR' metric, NULL repair_uid, count(*) den
from ossams_mart.tb_dm_ossams_repair_fact a,
     ossams_mart.tb_sa_ossams_service_code_lkp b,
     ossams_mart.tb_ossams_tas_code_lkp c,
     ossams_mart.tb_ossams_service_type e
where to_char(a.load_date, 'yyyymmdd') between '20120219' and '20120225'
  and a.state in ('OR', 'WA', 'ID', 'NV', 'AZ', 'CA', 'OH', 'WI', 'IL')
  and a.report_source in ('1', '2', '3')
  and a.report_type in ('1', '2', '3', '4', '6')
  and a.dspsn in ('4', '6', '7', '9', '10', '11', '12','13','15')
  and a.invalid_ind not in ('I')
  and substr(a.modifier,2,1)not in ('U')
  and a.state = c.state
  and a.cntrl_offce = c.cntrl_offce
  and b.service_type in ('D7', 'A6', 'D6', 'S1')
  and b.st_category in ('Z')
  and a.service_code = b.service_code
  and b.service_type = e.service_type
or to_char(a.load_date, 'yyyymmdd') between '20120219' and '20120225'
  and a.state in ('OR', 'WA', 'ID', 'NV', 'AZ', 'CA', 'OH', 'WI', 'IL')
  and a.report_source in ('1', '2', '3')
  and a.report_type in ('1', '2', '3', '4', '6')
  and a.dspsn in ('4', '6', '7', '9', '10', '11', '12', '13','15')
  and a.invalid_ind not in ('I')
  and substr(a.modifier,2,1)not in ('U')
  and a.state = c.state
  and a.cntrl_offce = c.cntrl_offce
  and b.service_type in ('8')
  and b.st_category in ('Z')
  and a.service_code = b.service_code
  and b.service_type = e.service_type
  and (a.service_code='M8' and substr(a.ckt_id,2,7) LIKE '%T1%'
   or substr(a.ckt_id,2,7) LIKE '%T3%'
   or substr(a.ckt_id,2,7) LIKE '%OC3%'
   or substr(a.ckt_id,2,7) LIKE '%T04%'
   or substr(a.ckt_id,2,7) LIKE '%OC03%'
   or substr(a.ckt_id,2,7) LIKE '%OC12%'
   or substr(a.ckt_id,2,7) LIKE '%OC24%'
   or substr(a.ckt_id,2,7) LIKE '%OC48%'
   or substr(a.ckt_id,2,7) LIKE '%OC192%')
   group by service_type_descr, carrier_type, a.state 
   )
   group by region, metric
   order by region, metric 
 
   
 