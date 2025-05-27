
--LSR Orders Completed  

select region, sum(num) met, sum(den) orders, round((sum(num)/sum(den)*100),2) "% Met"
from ( 
select distinct pon, 
       case when tariff_code in ('ILC','ILF','ILS','OHF','MOH') then 'F9 Central'
	        when tariff_code in ('CAF','ORN','FWA','WAF','FWC') then 'F9 West'
			when tariff_code in ('AZF','IDF','NVC','WIF','WIL') then 'F9 National'
	   else 'Other' end region, 
       1 num, null den 
FROM CAMP.STG_SERVICE_ORDERS_LSR DPI 
where to_char(order_compl_dt,'yyyymmdd') = '20120410'  -- change to previous workday    
and ccna is not null 
and request_type not in ('JB','CB')
and activity_ind in ('N','C')
and order_compl_dt <= desired_due_date 
and desired_due_date is not null 
group by pon, tariff_code
UNION ALL 
select distinct pon, 
       case when tariff_code in ('ILC','ILF','ILS','OHF','MOH') then 'F9 Central'
	        when tariff_code in ('CAF','ORN','FWA','WAF','FWC') then 'F9 West'
			when tariff_code in ('AZF','IDF','NVC','WIF','WIL') then 'F9 National'
	   else 'Other' end region, 
       null num, 1 den 
FROM CAMP.STG_SERVICE_ORDERS_LSR DPI 
where to_char(order_compl_dt,'yyyymmdd') = '20120410'    -- change to previous workday  
and ccna is not null 
and request_type not in ('JB','CB')
and activity_ind in ('N','C')
and desired_due_date is not null
group by pon, tariff_code 
) 
group by region
order by 1

