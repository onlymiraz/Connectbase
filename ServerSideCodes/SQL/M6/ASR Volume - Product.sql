select distinct month, ccna, pon, version, reqtyp, act, icsc, sup_flag,
       case when NC in ('HC','HX') then 'DS1'
	        when substr(first_ecckt_id,4,2) in ('HC','HX','DH') then 'DS1'
			when substr(ckt,4,2) in ('HC','HX','DH') then 'DS1'
			when first_ecckt_id like '%/T1%' then 'DS1'
			when ckt like '%/T1%' then 'DS1'
			when substr(first_ecckt_id,1,2) = 'T-' then 'DS1'
			when substr(ckt,1,2) = 'T-' then 'DS1'
			when ckt like '%DHEC%' then 'DS1'
	        when NC = 'HF' then 'DS3'
			when substr(first_ecckt_id,4,2) = 'HF' then 'DS3'
			when substr(ckt,4,2) = 'HF' then 'DS3'
			when first_ecckt_id like '%/T3%' then 'DS3'
			when ckt like '%/T3%' then 'DS3'
			when substr(first_ecckt_id,1,3) = 'T3-' then 'DS3'
			when substr(ckt,1,3) = 'T3-' then 'DS3'
			when substr(nc,1,1) in ('X','L') then 'DS0'
			when substr(first_ecckt_id,4,1) in ('X','L') then 'DS0'
			when substr(first_ecckt_id,4,2) in ('SD') then 'DS0'
			when substr(ckt,4,2) in ('SD') then 'DS0'
			when substr(ckt,4,1) in ('X','L') then 'DS0'
			when substr(nc,1,1) = 'K' then 'Ethernet'
			when substr(first_ecckt_id,4,1) in ('K','V') then 'Ethernet'
			when substr(ckt,4,1) in ('K','V') then 'Ethernet'
			when substr(first_ecckt_id,1,2) = 'R2' then 'Ethernet'
			when substr(nc,1,1) = 'O' then 'OCN'
			when substr(first_ecckt_id,4,1) = 'O' then 'OCN'
			when first_ecckt_id like '%/OC%' then 'OCN'
			when substr(nc,1,1) = 'S' then 'Trunk'
			when substr(reqtyp,1,1) = 'M' then 'Trunk'
			when substr(reqtyp,1,1) = 'L' then 'CCS Link'
			else null end Product,
	   NC, ckt, first_ecckt_id
from (
select month, a.ccna, a.pon, version, reqtyp, act, icsc, sup_flag,NETWORK_CHANNEL_SERVICE_CODE NC, IC_CIRCUIT_REFERENCE ckt, first_ecckt_id
from (
SELECT DISTINCT * FROM (SELECT SUBSTR (MTH, 7, 13) AS MONTH, CCNA, pon, VERSION, REQTYP, act, icsc, SUP_FLAG FROM (
SELECT DISTINCT mth, CCNA, pon, VERSION, REQTYP, TO_CHAR(act) act, TO_CHAR(icsc) icsc, SUP_FLAG FROM (
SELECT                  TO_CHAR (urx.inserted_dt, 'mm:hh,MM/YYYY') AS MTH, 
                        CCNA, 
                        urx.external_order_no pon, 
                        VERSION, REQTYP, 
                        SUBSTR(urx.orig_xml, INSTR(orig_xml, 'ACT>')+ 4, 1) act, 
                        SUBSTR(urx.orig_xml, INSTR(orig_xml, 'ICSC>')+ 5, 4) icsc, 
                        DECODE(SUP, 1, 'Y', 2, 'Y', 3, 'Y', 4, 'Y', 'N') SUP_FLAG 
                   FROM asr_om.upstream_req_xml urx)) )WHERE MONTH LIKE '04/2014'
) a, access_service_request asr, serv_req sr
 where a.pon = sr.pon(+)
 and a.ccna = sr.ccna (+)
 and sr.document_number = asr.document_number (+)
 )				   
 ORDER BY MONTH ASC, PON, act

				   
