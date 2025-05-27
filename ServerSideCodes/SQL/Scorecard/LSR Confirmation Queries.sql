

--Past Due query 

select distinct pon, ver, reqtyp, act, tos, state, dpistate, tariff_code, 
       case when tariff_code in ('CAF','AZF','IDF','ILC','ILF','ILS','NVC','OHF','ORN','FWA','WAF','WIF','WIL','FWC','MOH') then 'FTR9'
	        when state not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
			when dpistate not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
			when state in ('WA','OH') then 'FTR9'
			when dpistate in ('WA','OH') then 'FTR9'
			else '??' end region, 
       flow_thru, ccna, dtsent_request, dtsent_response 
from ( 
SELECT vfo.pon, 
       max(vfo.ver) keep (dense_rank last order by dtsent_request) ver, 
	   vfo.reqtyp, vfo.act, vfo.tos, vfo.state, 
	   max(dpi.state) keep (dense_rank last order by dpi.upd_date) dpistate, 
	   max(dpi.tariff_code) keep (dense_rank last order by dpi.upd_date) tariff_code, 
       max(dpi.FLOW_THRU) keep (dense_rank last order by dpi.upd_date) flow_thru,
	   vfo.ccna, 
	   max(vfo.dtsent_request) dtsent_request, 
	   max(resp.dtsent_response) dtsent_response
FROM CAMP.STG_LSR_ORDER vfo, CAMP.STG_LSR_ORDER_RESPONSE resp, CAMP.STG_SERVICE_ORDERS_LSR dpi
WHERE vfo.PON = resp.PON (+) 
AND  vfo.VER = resp.VER (+) 
AND vfo.PON = dpi.PON (+)
and vfo.ccna = dpi.ccna (+)
AND to_char(vfo.DTSENT_REQUEST,'yyyymmdd') >= '20120301'  -- DO NOT CHANGE THIS DATE   
and to_char(resp.dtsent_response,'yyyymmdd') is null 
group by vfo.pon, vfo.reqtyp, vfo.act, vfo.tos, vfo.state, vfo.ccna
)
order by 1,2,5


-- LSR Volumes    


select region, count(*)
from (
select distinct pon, ver, state, dpistate, tariff_code, 
       case when tariff_code in ('CAF','AZF','IDF','ILC','ILF','ILS','NVC','OHF','ORN','FWA','WAF','WIF','WIL','FWC','MOH') then 'FTR9'
	        when state not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
			when dpistate not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
			when state in ('WA','OH') then 'FTR9'
			when dpistate in ('WA','OH') then 'FTR9'
			else '??' end region
from ( 
SELECT distinct vfo.pon, vfo.ver, vfo.state, 
	   max(dpi.state) keep (dense_rank last order by dpi.upd_date) dpistate, 
	   max(dpi.tariff_code) keep (dense_rank last order by dpi.upd_date) tariff_code, 
       max(vfo.dtsent_request) dtsent_request
FROM CAMP.STG_LSR_ORDER vfo, CAMP.STG_LSR_ORDER_RESPONSE resp, CAMP.STG_SERVICE_ORDERS_LSR dpi
WHERE vfo.PON = resp.PON (+) 
AND  vfo.VER = resp.VER (+) 
AND vfo.PON = dpi.PON (+)
and vfo.ccna = dpi.ccna (+)
AND to_char(vfo.DTSENT_REQUEST,'yyyymmdd') = '20120305'  -- yesterday's date   
group by vfo.pon, vfo.ver, vfo.state
))
group by region
order by 1,2




--Confirmation Complete and On Time   

select distinct pon, ver, reqtyp, act, tos, state, dpistate, tariff_code, 
       case when tariff_code in ('CAF','AZF','IDF','ILC','ILF','ILS','NVC','OHF','ORN','FWA','WAF','WIF','WIL','FWC','MOH') then 'FTR9'
	        when state not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
			when dpistate not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
			when state in ('WA','OH') then 'FTR9'
			when dpistate in ('WA','OH') then 'FTR9'
			else '??' end region, 
       flow_thru, ccna, dtsent_request, dtsent_response
from (
SELECT distinct vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state, 
       max(dpi.state) keep (dense_rank last order by dpi.upd_date) dpistate, 
	   max(dpi.tariff_code) keep (dense_rank last order by dpi.upd_date) tariff_code, 
       max(dpi.FLOW_THRU) keep (dense_rank last order by dpi.upd_date) flow_thru, 
	   vfo.ccna, 
       max(vfo.dtsent_request) dtsent_request, 
	   max(resp.dtsent_response) dtsent_response
FROM CAMP.STG_LSR_ORDER vfo, CAMP.STG_LSR_ORDER_RESPONSE resp, CAMP.STG_SERVICE_ORDERS_LSR dpi
WHERE vfo.PON = resp.PON (+) 
AND  vfo.VER = resp.VER (+) 
AND vfo.PON = dpi.PON (+)
and vfo.ccna = dpi.ccna (+)
and vfo.order_channel = 'DI'
and resp.response_type = 'LR'
AND to_char(resp.DTSENT_RESPONSE,'yyyymmdd') = '20120305'   -- yesterday's date   
group by vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state, vfo.ccna
)
order by 1,2,5

,