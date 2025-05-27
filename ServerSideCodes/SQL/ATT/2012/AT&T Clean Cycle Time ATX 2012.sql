  select service, sum(aiti_bus_days) int, count(*) cnt
   from ( 
	select case when substr(prchs_order_no,3,1) = 'H' then 'Inter-office Facilities'
	   when substr(nc,1,1) in ('K','V') then 'Ethernet ATX'
	   when (substr(nc,1,2) in ('OB','JJ') and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC3'
	   when (substr(nc,1,2) in ('OB','JJ') and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX OC3'
	   when (substr(nc,1,2) = 'OD' and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC12'
	   when (substr(nc,1,2) = 'OD' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX OC12'
	   when (substr(nc,1,2) = 'OF' and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC48'
	   when (substr(nc,1,2) = 'OF' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX OC48'
	   when (substr(nc,1,2) = 'OG' and substr(prchs_order_no,3,2) = 'S0') then 'ATX OC192'
	   when (substr(nc,1,2) = 'OG' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX OC192'
	   when (substr(nc,1,1) in ('O','H') and substr(prchs_order_no,3,2) = 'SA') then 'A RING SCI'
	   when (substr(nc,1,1) in ('O') and substr(prchs_order_no,3,2) = 'SR') then 'A RING'
	   when (substr(nc,1,1) in ('L','X') and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL DS0'
	   when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F')) then 'ATX DS1'
	   when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,4,1) in ('P','Y')) then 'ATX DS1'
	   when (substr(nc,1,2) = 'HC' and substr(prchs_order_no,3,1) in ('S','H') and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL DS1'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,3,1) = 'S' and substr(prchs_order_no,4,1) in ('0','F')) then 'ATX DS3'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,4,1) in ('P','Y')) then 'ATX DS3'
	   when (substr(nc,1,2) = 'HF' and substr(prchs_order_no,3,1) in ('S','H') and substr(prchs_order_no,4,1) <> 'A') then 'ATX ALL DS3'
	   else 'UNDEFINED' end service,
     aiti_bus_days
    from OSSAMS_MART.TB_DM_OSSAMS_PRVSN_FACT a, OSSAMS_MART.TB_OSSAMS_RCA_DETAIL b
    where a.prvsn_uid = b.record_uid(+)
    and TO_CHAR(LOAD_DATE, 'YYYYMM') = '201202'  ---CHANGE DATES 
    and z_action in ('A','C','I','N','T')
    and invalid_ind not in ('I')
    and to_cd <> ' '
	and substr(clli_z,5,2) in ('AZ','CA','ID','IL','NV','OH','OR','WA','WI') --'IN','MI','NC','SC' 
	and ccna in ('ATX','TPM','AAV','SBB','SBZ','SUV')
	)
	where service <> 'UNDEFINED'
	group by service
	order by service
	



