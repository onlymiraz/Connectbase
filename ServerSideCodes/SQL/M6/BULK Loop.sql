---Detail  

select TXNUM, SUBSTR(TXNUM,1,11) ORDNO, SUBSTR(TXNUM,13,4) CNT, DT_SENT_REQUEST, TXTYP, TXACT, STATE,
INTERFACE_ID, 
CASE WHEN SUBSTR(INTERFACE_ID,1,3) = 'APC' THEN 'Access Point'
     WHEN SUBSTR(INTERFACE_ID,1,3) = 'BCN' THEN 'BCN'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'CRTCOM' THEN 'Charter'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'NWOLVS' THEN 'NetWolves'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'SGNDSL' THEN 'SageNet'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'SPCTRL' THEN 'SpectroTel'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'TELDSL' THEN 'TelDSL'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'CONVCM' THEN 'CONVCM'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'OHIOTC' THEN 'OhioTC'
     ELSE NULL END CARRIER,
ORDER_CHANNEL, LOAD_DATE, RPT_YEAR_MON                 
from camp.stg_lsr_pre_order                
where txtyp in ('H','X')
and txnum like 'BULK%'  
and rpt_year_mon = '201803'              
order by 4;                




--to get Order Summary  

select carrier, rpt_year_mon, count(*) cnt
from (
select distinct carrier, ordno, rpt_year_mon 
from (
select TXNUM, SUBSTR(TXNUM,1,11) ORDNO, SUBSTR(TXNUM,13,4) TN, DT_SENT_REQUEST, TXTYP, TXACT, STATE,
INTERFACE_ID, 
CASE WHEN SUBSTR(INTERFACE_ID,1,3) = 'APC' THEN 'Access Point'
     WHEN SUBSTR(INTERFACE_ID,1,3) = 'BCN' THEN 'BCN'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'CRTCOM' THEN 'Charter'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'NWOLVS' THEN 'NetWolves'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'SGNDSL' THEN 'SageNet'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'SPCTRL' THEN 'SpectroTel'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'TELDSL' THEN 'TelDSL'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'CONVCM' THEN 'CONVCM'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'OHIOTC' THEN 'OhioTC'
     ELSE NULL END CARRIER,
ORDER_CHANNEL, LOAD_DATE, RPT_YEAR_MON                 
from camp.stg_lsr_pre_order                
where txtyp in ('H','X')
and txnum like 'BULK%'
and rpt_year_mon = '201803' 
))
group by carrier, rpt_year_mon               
order by 1,2;             


--to get Address Summary  


select carrier, rpt_year_mon, count(*) 
from (
select TXNUM, SUBSTR(TXNUM,1,11) ORDNO, SUBSTR(TXNUM,13,4) TN, DT_SENT_REQUEST, TXTYP, TXACT, STATE,
INTERFACE_ID, 
CASE WHEN SUBSTR(INTERFACE_ID,1,3) = 'APC' THEN 'Access Point'
     WHEN SUBSTR(INTERFACE_ID,1,3) = 'BCN' THEN 'BCN'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'CRTCOM' THEN 'Charter'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'NWOLVS' THEN 'NetWolves'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'SGNDSL' THEN 'SageNet'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'SPCTRL' THEN 'SpectroTel'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'TELDSL' THEN 'TelDSL'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'CONVCM' THEN 'CONVCM'
     WHEN SUBSTR(INTERFACE_ID,1,6) = 'OHIOTC' THEN 'OhioTC'
     ELSE NULL END CARRIER,
ORDER_CHANNEL, LOAD_DATE, RPT_YEAR_MON                 
from camp.stg_lsr_pre_order                
where txtyp in ('H','X')
and txnum like 'BULK%'
and rpt_year_mon = '201803' 
)
group by carrier, rpt_year_mon               
order by 1,2;             