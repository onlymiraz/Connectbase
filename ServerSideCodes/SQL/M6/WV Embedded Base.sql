drop table APRlines;



create table APRLines nologging nocache as
select ckt, icsc, prod, clec_id,
       state, svc_cd, nc,  
	   case when substr(icsc,1,2) = 'FV' then 'ACQ'
	        when icsc is not null then 'LEG'
	   		when icsc is null and state in ('AZ','CA','ID','IL','IN','MI','NV','NC','OH','OR','SC','WA','WI','WV','KY','MO','MD') then 'ACQ'
			when state in ('DE','GA','IA','MN','ND','NE','NJ','PA','VA') then 'LEG'
			else '??' end area, 
			ordnum, lastmod, trunc(issue_date) issue_date, aclli, zclli, rate, type
from (
select ckt, icsc,  
       case when substr(ckt,4,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN') then 'DS0'
	        when substr(ckt,4,2) in ('HC','HX','YB','YG','T1') then 'DS1' 
	        when substr(ckt,4,2) in ('HF','LX','YI','T3') then 'DS3'
			when substr(ckt,4,2) in ('OB','OD','OF','OG','OC') then 'OCN'
			when substr(ckt,4,2) in ('KD','KE','KF','KG','KQ','KR','VL') then 'Ethernet'
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
	   acna, ccna, svc_cd, nc, issue_date, ordnum, lastmod, aclli, zclli, rate, type
from (
select exchange_carrier_circuit_id ckt,
       max(ec_company_code) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(rate_code) keep (dense_rank last order by c.last_modified_date) rate,
	   max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna,  
	   MAX(SUBSTR(NL1.CLLI_CODE,5,2)) keep (dense_rank last order by nl1.last_modified_date) astate,
       MAX(SUBSTR(NL2.CLLI_CODE,5,2)) keep (dense_rank last order by nl2.last_modified_date) zstate,
       MAX(NL1.CLLI_CODE) keep (dense_rank last order by nl1.last_modified_date) aclli,
       MAX(NL2.CLLI_CODE) keep (dense_rank last order by nl2.last_modified_date) zclli,
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
	   max(substr(d.order_nbr,1,3)) keep (dense_rank last order by d.last_modified_date) ordnum,
	   max(d.last_modified_userid)  keep (dense_rank last order by d.last_modified_date) lastmod,
	   max(d.network_channel_code) keep (dense_rank last order by d.last_modified_date) nc,
	   max(d.issue_date) keep (dense_rank last order by d.last_modified_date) issue_date,
       max(c.type) keep (dense_rank last order by c.last_modified_date) type
from circuit c, 
     design_layout_report d, 
	 network_location nl1,
	 network_location nl2
where c.exchange_carrier_circuit_id = d.ecckt
and c.LOCATION_ID = NL1.LOCATION_ID(+)
and c.location_id_2 = nl2.location_id(+)
--and c.type <> 'T'
--and d.ccna is not null
group by exchange_carrier_circuit_id
)
where status = '6'
)						   
--where clec_id not in ('FLR','CUS','ZZZ','ERR','CQV','BNK','.','254','256','304','306','310','319','600','999',
  --                  '1ZZ','3','C05','C2','C50','GOV')
;
							



select customer, prod, count(*)
from APRlines
where prod in ('DS0','DS1','DS3','OCN','Ethernet')
--and customer = 'LUMOS'
--and AREA = 'ACQ'
group by customer, prod
order by 1,2;



select prod, count(*)
from aprlines
where state = 'WV'
group by prod;

group by astate
order by astate