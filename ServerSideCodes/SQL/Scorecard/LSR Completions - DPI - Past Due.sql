
--LSR Orders Past Due    
 

select region, count(*) "Past Due" 
from (
select pon,  
       case when tariff in ('ILC','ILF','ILS','OHF','MOH') then 'F9 Central'
	        when tariff in ('CAF','ORN','FWA','WAF','FWC') then 'F9 West'
			when tariff in ('AZF','IDF','NVC','WIF','WIL') then 'F9 National'
	   else 'Other' end region,
	   dd, comp
from (
select distinct pon, 
       max(tariff_code) keep (dense_rank last order by upd_date) tariff,  
       max(desired_due_date) keep (dense_rank last order by upd_date) dd,
	   max(order_compl_dt) keep (dense_rank last order by upd_date) comp,
	   max(supplement_type) keep (dense_rank last order by upd_date) supp
FROM CAMP.STG_SERVICE_ORDERS_LSR DPI 
where pon in (
select distinct pon
from CAMP.STG_SERVICE_ORDERS_LSR DPI
where to_char(desired_due_date,'yyyymmdd') between '20120215' and '20120410'   -- change the last date to previous workday - leave first date as is    
and ccna is not null 
and request_type not in ('JB','CB')
and activity_ind in ('N','C')
) 
group by pon
)
where (supp <> '1' or supp is null)
and to_char(dd,'yyyymmdd') between '20120215' and '20120410'   -- change the last date to previous workday - leave first date as is  
and comp is null
and dd is not null
)
group by region
order by 1

