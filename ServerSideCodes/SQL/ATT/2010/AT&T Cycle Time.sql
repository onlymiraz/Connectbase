select NDD.ASR_NO, AD.SVC_ST, DECODE(NDD.PROD_CAT,'HICAP',NDD.PROD_SUBCAT,'DS0') SERVICE,
MET, NDD.ACT, NC_CD, D_REC, DT ACT_DT, 
NDD.ACNA, NDD.CCNA, DDD, NDD.PON, EXP_IND, DD, PIU, WIRELESS_IND





select *
from NACCPROD.ASR_DIM AD, NACCPROD.NACC_DAILY_DETAIL NDD, NACCPROD.CARRIER_LOOKUP CL 
where to_char(ndd.dt, 'yyyy') = to_char(sysdate, 'yyyy')
and to_char(ndd.dt, 'mm') = (to_char(sysdate, 'mm')-1)
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
and CL.AFF_CAT = 'Non-Affiliate'


select ad.ccna, app_dt, d_rec, dd, ddd, jeop_cd, mp_ctl, mp_ind, ad.pon, stat, vers, ad.version, ord, comp_dt, center_id, measure_id, jeop 
from naccprod.asr_dim AD, NACCPROD.NACC_DAILY_DETAIL NDD



select ord, max(d_rec) --app_dt, d_rec, ord, ad.version, measure_id
from naccprod.asr_dim AD, NACCPROD.NACC_DAILY_DETAIL NDD
where AD.ASR_ID = NDD.ASR_ID_VERSION
and stat= 'COMP'
--and measure_id = '16'
and ad.ord in (
'CGC9251386150',
'CGC9341386238',
'CGC9341386240',
'CGC9356386276',
'NCN0125386114',
'NGN0089886162'
)
group by ord
order by ord


select * --ord, max(d_rec) --app_dt, d_rec, ord, ad.version, measure_id
from naccprod.asr_dim AD, NACCPROD.NACC_DAILY_DETAIL NDD
where AD.ASR_ID = NDD.ASR_ID_VERSION
--and stat= 'COMP'
--and measure_id = '16'
and ad.ord = 'CGC9341386238'

select distinct so_no, d_rec
from naccprod.ddd_details
where so_no in ( 
'CAC0083386133',
'CAC0106886073',
'CAC0116886117',
'CAC0116886185',
)
order by so_no