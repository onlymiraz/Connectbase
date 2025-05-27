select trunc(ndd.dt, 'MM') as age_date, NDD.ASR_NO, AD.SVC_ST, DECODE(NDD.PROD_CAT,'HICAP',NDD.PROD_SUBCAT,'DS0') SERVICE,
NULL Met, 1 Count, NULL Interval, 
MET, NDD.ACT, NC_CD, D_REC, DT ACT_DT, CL.CSET,  
NDD.ACNA, NDD.CCNA, DDD, NDD.PON, EXP_IND, DD, PIU, WIRELESS_IND, prjct, ad.proj_ind, proj_init
from NACCPROD.ASR_DIM AD, NACCPROD.NACC_DAILY_DETAIL NDD, NACCPROD.CARRIER_LOOKUP CL 
where to_char(ndd.dt, 'yyyymm') = '201111' 
and AD.ASR_ID = NDD.ASR_ID_VERSION 
and NDD.CCNA = CL.CCNA 
and MEASURE_ID = 27 
and NDD.PROD_CAT IN ('HICAP','NON-HICAP')
and EXCLD_IND = 'N'
and NVL(PROJ_INIT,'N')!= 'I'
and CENTER_ID IN (2, 4, 8, 10) 
and PIU = '0'
and AD.SVC_ST = 'IL'
and NDD.CCNA NOT IN ('CUS', 'ZZZ')
--and CL.AFF_CAT = 'Non-Affiliate'
and dt >= d_rec
and prjct = 'NONE'

