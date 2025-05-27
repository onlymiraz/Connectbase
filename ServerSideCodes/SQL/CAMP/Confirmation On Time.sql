--Confirmation Complete and On Time OLD      

select distinct pon, ver, reqtyp, act, tos, vfostate, dpistate, tariff_code, 
        CASE WHEN vfostate IS NOT NULL THEN vfostate
         WHEN dpistate IS NOT NULL THEN dpistate
         WHEN tariff_code IS NOT NULL THEN SUBSTR(tariff_code,1,2)
         ELSE 'zz_null' END State,
       case when tariff_code in ('CAF','AZF','IDF','ILC','ILF','ILS','NVC','OHF','ORN','FWA','WAF','WIF','WIL','FWC','MOH') then 'FTR9'
                        when vfostate not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
                                                when dpistate not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
                                                when vfostate in ('WA','OH') then 'FTR9'
                                                when dpistate in ('WA','OH') then 'FTR9'
                                                else '??' end region, 
       flow_thru, rep, ccna, response_type,
       TO_CHAR(dtsent_request, 'mm/dd/yyyy') dsent_request, 
       TO_CHAR(dtsent_request, 'hh24:mi') tsent_request, 
       TO_CHAR(dtsent_request, 'mm/dd/yyyy  hh24:mi') dtsent_request, 
       TO_CHAR(eptimestamp_response, 'mm/dd/yyyy') epdstamp_response,
       TO_CHAR(eptimestamp_response, 'hh24:mi') eptstamp_response,
       --TO_CHAR(dtsent_response, 'mm/dd/yyyy  hh24:mi') dtsent_response REPLACE WITH EP_TIMESTAMP BELOW
       TO_CHAR(eptimestamp_response, 'mm/dd/yyyy  hh24:mi') epdtstamp_response
from (
SELECT distinct vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state vfostate, 
       max(dpi.state) keep (dense_rank last order by dpi.upd_date) dpistate, 
                   max(dpi.tariff_code) keep (dense_rank last order by dpi.upd_date) tariff_code, 
       max(dpi.FLOW_THRU) keep (dense_rank last order by dpi.upd_date) flow_thru, 
                   resp.rep, vfo.ccna, resp.response_type,
       max(vfo.dtsent_request) dtsent_request, 
       --max(resp.dtsent_response) dtsent_response REPLACE WITH EP_TIMESTAMP BELOW
       resp.ep_timestamp eptimestamp_response
FROM CAMP.STG_LSR_ORDER vfo, CAMP.STG_LSR_ORDER_RESPONSE resp, CAMP.STG_SERVICE_ORDERS_LSR dpi
WHERE vfo.PON = resp.PON (+) 
AND  vfo.VER = resp.VER (+) 
AND vfo.PON = dpi.PON (+)
and vfo.ccna = dpi.ccna (+)
and vfo.order_channel = 'DI'
and resp.response_type in ('LR','ERROR','JEOPARDY')
and vfo.pon = 'GRT1545326997'
--AND to_char(resp.DTSENT_RESPONSE,'yyyymmdd') = '20120614'   -- yesterday's date   REPLACE WITH EP_TIMESTAMP BELOW
AND to_char(resp.EP_TIMESTAMP,'yyyymmdd') BETWEEN '20120828' AND '20120828'  -- yesterday's date  or Friday-to-Sunday range 
group by vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state, resp.rep, vfo.ccna, resp.response_type, resp.ep_timestamp
)
order by 1,2,5

--UPDATED    
select distinct pon, ver, reqtyp, act, tos, vfostate, dpistate, tariff_code, 
        CASE WHEN vfostate IS NOT NULL THEN vfostate
         WHEN dpistate IS NOT NULL THEN dpistate
         WHEN tariff_code IS NOT NULL THEN SUBSTR(tariff_code,1,2)
         ELSE 'zz_null' END State,
       case when tariff_code in ('CAF','AZF','IDF','ILC','ILF','ILS','NVC','OHF','ORN','FWA','WAF','WIF','WIL','FWC','MOH') then 'FTR9'
                        when vfostate not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
                                                when dpistate not in ('AZ','CA','ID','IL','OH','OR','NV','WA','WI') then 'Other'
                                                when vfostate in ('WA','OH') then 'FTR9'
                                                when dpistate in ('WA','OH') then 'FTR9'
                                                else '??' end region, 
       flow_thru, rep, ccna, response_type,
       TO_CHAR(dtsent_request, 'mm/dd/yyyy') dsent_request, 
       TO_CHAR(dtsent_request, 'hh24:mi') tsent_request, 
       TO_CHAR(dtsent_request, 'mm/dd/yyyy  hh24:mi') dtsent_request, 
       TO_CHAR(eptimestamp_response, 'mm/dd/yyyy') epdstamp_response,
       TO_CHAR(eptimestamp_response, 'hh24:mi') eptstamp_response,
       --TO_CHAR(dtsent_response, 'mm/dd/yyyy  hh24:mi') dtsent_response REPLACE WITH EP_TIMESTAMP BELOW
       TO_CHAR(eptimestamp_response, 'mm/dd/yyyy  hh24:mi') epdtstamp_response
from (
SELECT distinct vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state vfostate, 
       max(dpi.state) keep (dense_rank last order by dpi.upd_date) dpistate, 
                   max(dpi.tariff_code) keep (dense_rank last order by dpi.upd_date) tariff_code, 
       max(dpi.FLOW_THRU) keep (dense_rank last order by dpi.upd_date) flow_thru, 
                   resp.rep, vfo.ccna, resp.response_type,
       max(vfo.dtsent_request) dtsent_request, 
       --max(resp.dtsent_response) dtsent_response REPLACE WITH EP_TIMESTAMP BELOW
       --max(resp.ep_timestamp) eptimestamp_response
       resp.ep_timestamp eptimestamp_response 
FROM CAMP.STG_LSR_ORDER vfo, CAMP.STG_SERVICE_ORDERS_LSR dpi, --CAMP.STG_LSR_ORDER_RESPONSE resp, 
      (select pon, ver, response_type, rep, max(ep_timestamp) keep (dense_rank first order by load_date) ep_timestamp 
      from CAMP.STG_LSR_ORDER_RESPONSE group by pon, ver, response_type, rep) resp
WHERE vfo.PON = resp.PON (+) 
AND  vfo.VER = resp.VER (+) 
AND vfo.PON = dpi.PON (+)
and vfo.ccna = dpi.ccna (+)
and vfo.order_channel = 'DI'
and resp.response_type in ('LR','ERROR','JEOPARDY')
and vfo.pon = 'GRT1545326997'
--AND to_char(resp.DTSENT_RESPONSE,'yyyymmdd') = '20120614'   -- yesterday's date   REPLACE WITH EP_TIMESTAMP BELOW
--AND to_char(resp.EP_TIMESTAMP,'yyyymmdd') BETWEEN '20120828' AND '20120828'  -- yesterday's date  or Friday-to-Sunday range 
group by vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state, resp.rep, vfo.ccna, resp.response_type, resp.ep_timestamp
)
order by 1,2,5
