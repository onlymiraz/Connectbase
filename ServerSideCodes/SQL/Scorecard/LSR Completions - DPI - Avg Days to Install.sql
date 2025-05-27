

--LSR Completed Orders Average Days to Install  

select region, complete_date, count(*) comp_orders, round(avg(days),1) avg_days
from (
select distinct pon, trunc(order_compl_dt) complete_date, create_date, request_type, order_compl_dt-create_date days,
       case when tariff_code in ('ILC','ILF','ILS','OHF','MOH') then 'F9 Central'
	        when tariff_code in ('CAF','ORN','FWA','WAF','FWC') then 'F9 West'
			when tariff_code in ('AZF','IDF','NVC','WIF','WIL') then 'F9 National'
	   else 'Other' end region
FROM CAMP.STG_SERVICE_ORDERS_LSR DPI 
where to_char(order_compl_dt,'yyyymmdd') = '20120410'    -- change to previous workday   
and ccna is not null  
and request_type not in ('JB','CB')
and activity_ind in ('N','C')
and desired_due_date is not null
)
group by region, complete_date
order by region


