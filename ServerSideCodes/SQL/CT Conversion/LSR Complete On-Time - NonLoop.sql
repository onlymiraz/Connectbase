
--LSR Orders Completed  

select 'Loop' product, sum(num) met, sum(den) orders, round((sum(num)/sum(den)*100),2) "% Met", sum(backlog) past_due
from ( 
select distinct pon,
       1 num, null den, null backlog
FROM CAMP.STG_SERVICE_ORDERS_LSR DPI 
where to_char(order_compl_dt,'yyyymmdd') = '20141121'  -- change to previous workday    
and (ccna not in ('FTR') 
     and substr(ccna,1,1) <> 'Z'
     and ccna is not null) 
and request_type not in ('AB','BB')
and activity_ind in ('N','C')
and order_compl_dt <= desired_due_date
and desired_due_date is not null 
and tariff_code = 'CTA'
and (supplement_type <> 1 or supplement_type is null)
--
UNION ALL 
--
select distinct pon, 
       null num, 1 den, null backlog
FROM CAMP.STG_SERVICE_ORDERS_LSR DPI 
where to_char(order_compl_dt,'yyyymmdd') = '20141121'    -- change to previous workday  
and (ccna not in ('FTR') 
     and substr(ccna,1,1) <> 'Z'
     and ccna is not null) 
and request_type not in ('AB','BB')
and activity_ind in ('N','C')
and desired_due_date is not null
and tariff_code = 'CTA'
and (supplement_type <> 1 or supplement_type is null)
--
UNION ALL 
--
select distinct pon, null num, null den, 1 backlog 
from (
select distinct document_number, pon,  
       max(desired_due_date) keep (dense_rank last order by dpi.load_date) dd,
	   max(order_compl_dt) keep (dense_rank last order by dpi.load_date) comp,
	   max(supplement_type) keep (dense_rank last order by dpi.load_date) supp
FROM CAMP.STG_SERVICE_ORDERS_LSR DPI
where (ccna not in ('FTR') 
     and substr(ccna,1,1) <> 'Z'
     and ccna is not null) 
and request_type not in ('AB','BB')
and activity_ind in ('N','C')
and desired_due_date is not null
and tariff_code = 'CTA'
group by document_number, pon
)
where to_char(dd,'yyyymmdd') <= '20141121'
and comp is null 
and (supp <> 1 or supp is null)
) 
order by 1





