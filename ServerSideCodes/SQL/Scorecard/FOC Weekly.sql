
select sum(met) num, count(*) den, sum(met)/count(*)*100 res
 from (
select case when district is null and state in ('AZ','CA','NV','WI') then 'Potts'
		 when district is null and state in ('IL') then 'Illinois'
		 when district is null and state in ('NC') then 'North Carolina'
		 when district is null and state in ('SC') then 'South Carolina'
		 when district is null and state in ('OH') then 'Ohio'
		 when district is null and state in ('OR') then 'Oregon'
		 when district is null and state in ('WA') then 'Washington'
		 when district is null and state in ('ID') then 'Towne'
		 when district is null and state in ('MI') then 'North District'
		 when district is null and state in ('IN') then 'South District'
        else district end district, met
 from (		
select ad.prod_subcat,
        case when met = 'Y' then 1 else 0 end met, 
ad.svc_st state, district, secloc_swc
from NACCPROD.ASR_DIM AD, NACCPROD.NACC_DAILY_DETAIL NDD, TEMP_HIER6_NATIONAL HIER
where to_char(ndd.dt, 'yyyymmdd') between '20120219' and '20120225' 
and AD.ASR_ID = NDD.ASR_ID_VERSION 
--and NDD.CCNA = CL.CCNA
and substr(AD.SECLOC_SWC,1,6) = HIER.CLLI6(+)  
and MEASURE_ID = 27 
and EXCLD_IND = 'N'
and NVL(PROJ_INIT,'N')!= 'I'
and CENTER_ID IN (2, 4, 8, 10)
and ad.svc_cat = 'SPECIAL' 
and ndd.prod_subcat in ('DS1','DS3','DDS','VG','SONET')
and AD.SVC_ST in ('OR', 'WA', 'ID', 'NV', 'AZ', 'CA', 'OH', 'WI', 'IL')
 ))



