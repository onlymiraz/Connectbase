drop table APRlinesLumos;



--create table APRLinesLumos nologging nocache as

select ckt, icsc, prod, clec_id,
       case when clec_id in ('FWN','FET') then 'LUMOS'
			else null end CUSTOMER,
       state, svc_cd, nc, 
	   case when substr(icsc,1,2) = 'FV' then 'ACQ'
	        when icsc is not null then 'LEG'
	   		when icsc is null and state in ('AZ','CA','ID','IL','IN','MI','NV','NC','OH','OR','SC','WA','WI','WV','KY','MO','MD') then 'ACQ'
			when state in ('DE','GA','IA','MN','ND','NE','NJ','PA','VA') then 'LEG'
			else '??' end area, 
			ckt_status, si_status
from (
select ckt, icsc,  
       case when substr(ckt,4,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN','LX') then 'DS0'
	        when substr(ckt,4,2) in ('HC','HX','YB','YG','T1') then 'DS1' 
	        when substr(ckt,4,2) in ('HF','LX','YI','T3') then 'DS3'
			when substr(ckt,4,2) in ('OB','OD','OF','OG','OC') then 'OCN'
			when substr(ckt,4,2) in ('KD','KE','KF','KG','KQ','KR','KS','KJ','VL','SX') then 'Ethernet'
			when substr(ckt,6,2) = 'T1' then 'DS1'
			when substr(ckt,6,2) = 'T3' then 'DS3'
			when substr(svc_cd,1,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN') then 'DS0'
			when substr(svc_cd,1,2) in ('HC','HX','YB','YG','T1') then 'DS1'
			when substr(svc_cd,1,2) in ('HF','LX','YI','T3') then 'DS3'
			when substr(svc_cd,1,1) in ('K','V') then 'Ethernet'
			when substr(svc_cd,1,1) = 'O' then 'OCN'
			else rate end prod,
	   case when acna = 'BNK' then ccna
	        when acna is not null then acna
	        else ccna end clec_id,
	   case when zstate is not null then zstate
	        else astate end state,	
	   acna, ccna, svc_cd, nc, ckt_status, si_status
from (
select exchange_carrier_circuit_id ckt,
       max(ec_company_code) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(rate_code) keep (dense_rank last order by c.last_modified_date) rate,
	   max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna,  
	   MAX(SUBSTR(NL1.CLLI_CODE,5,2)) keep (dense_rank last order by nl1.last_modified_date) astate,
       MAX(SUBSTR(NL2.CLLI_CODE,5,2)) keep (dense_rank last order by nl2.last_modified_date) zstate,
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
	   max(substr(d.order_nbr,1,3)) keep (dense_rank last order by d.last_modified_date) ordnum,
	   max(d.last_modified_userid)  keep (dense_rank last order by d.last_modified_date) lastmod,
	   max(d.network_channel_code) keep (dense_rank last order by d.last_modified_date) nc,
       max(c.status) keep (dense_rank last order by c.last_modified_date) ckt_status,
       si.status si_status
from circuit c, 
     design_layout_report d, 
	 network_location nl1,
	 network_location nl2,
     serv_item si
where c.exchange_carrier_circuit_id = d.ecckt
and c.LOCATION_ID = NL1.LOCATION_ID(+)
and c.location_id_2 = nl2.location_id(+)
and c.circuit_design_id = si.circuit_design_id
and c.type <> 'T'
and d.ccna is not null
and (d.acna in ('FET','FWN')
  or d.ccna in ('FET','FWN'))
group by exchange_carrier_circuit_id, si.status
)
--where substr(ckt,7,1) <> 'U'
where si_status = '6' and ckt_status <> '8'
and substr(svc_cd,1,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN','LX',
                		   'HC','HX','YB','YG','T1',
			   			   'HF','LX','YI','T3',
			   			   'OB','OD','OF','OG','OC',
						   'KD','KE','KF','KG','KQ','KR','KS','KJ','VL','SX','SN')
)
order by 1
;						   

							



select prod, count(*)
from APRlinesLumos
where prod in ('DS0','DS1','DS3','OCN','Ethernet')
and customer = 'LUMOS'
group by prod;



select * from aprlineslumos
order by 1; 


