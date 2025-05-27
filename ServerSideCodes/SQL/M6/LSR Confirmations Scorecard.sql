

--Past Due query 
  
SELECT vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state, dpi.state, dpi.tariff_code, 
       case when dpi.tariff_code = 'WVV' then 'WVA'
	        when dpi.tariff_code in ('IN','INC','INA','MI','MIM','NC','NCC','SCC','SC') then 'FTR4'
			when dpi.tariff_code is null and vfo.state in ('NC','SC') then'FTR4'
			when dpi.tariff_code is null and vfo.state in ('MI','IN','WV') then '??'
			when dpi.tariff_code is null and vfo.state is null then '??'
	        else 'Legacy' end region,
	   dpi.FLOW_THRU, vfo.ccna, 
       max(vfo.dtsent_request), max(resp.dtsent_response)
FROM CAMP.STG_LSR_ORDER vfo, CAMP.STG_LSR_ORDER_RESPONSE resp, CAMP.STG_SERVICE_ORDERS_LSR dpi
WHERE vfo.PON = resp.PON (+) 
AND  vfo.VER = resp.VER (+) 
AND vfo.PON = dpi.PON (+)
and vfo.ccna = dpi.ccna (+)
AND to_char(vfo.DTSENT_REQUEST,'yyyymmdd') >= '20111001'
and to_char(resp.dtsent_response,'yyyymmdd') is null 
group by vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state, dpi.state, dpi.tariff_code, dpi.FLOW_THRU, vfo.ccna


--Confirmation Complete and On Time   

SELECT vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state, dpi.state, dpi.tariff_code, 
       case when dpi.tariff_code = 'WVV' then 'WVA'
	        when dpi.tariff_code in ('IN','INC','INA','MI','MIM','NC','NCC','SCC','SC') then 'FTR4'
			when dpi.tariff_code is null and vfo.state in ('NC','SC') then'FTR4'
			when dpi.tariff_code is null and vfo.state in ('MI','IN','WV') then '??'
			when dpi.tariff_code is null and vfo.state is null then '??'
	        else 'Legacy' end region,
       dpi.FLOW_THRU, vfo.ccna, 
       max(vfo.dtsent_request), max(resp.dtsent_response) 
FROM CAMP.STG_LSR_ORDER vfo, CAMP.STG_LSR_ORDER_RESPONSE resp, CAMP.STG_SERVICE_ORDERS_LSR dpi
WHERE vfo.PON = resp.PON (+) 
AND  vfo.VER = resp.VER (+) 
AND vfo.PON = dpi.PON (+)
and vfo.ccna = dpi.ccna (+)
and resp.response_type = 'LR'
AND to_char(resp.DTSENT_RESPONSE,'yyyymmdd') = '20111013'   -- yesterday's date   
group by vfo.pon, vfo.ver, vfo.reqtyp, vfo.act, vfo.tos, vfo.state, dpi.state, dpi.tariff_code, dpi.FLOW_THRU, vfo.ccna
order by 1,2,5



