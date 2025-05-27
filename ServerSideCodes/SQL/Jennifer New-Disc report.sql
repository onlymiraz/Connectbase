
	  
--NEW ASRs (excluding SUPs)  	
  
select to_char(rec_trans_dt,'yyyymm') dt, svc_st, customer2 cust, a.acna, pon, prod_subcat
from naccprod.asr_volumes_details a, naccprod.ossams_acna_lkp b
where to_char(rec_trans_dt,'yyyymmdd') between '20120201' and '20120229'
and new_ind = 'Y'
and svc_st not in ('IN','MI','NC','SC')
and pon not like '%ORBIT%'
and a.acna = b.acna
order by 1,2,3,4,6



--DISC ASRs (excluding SUPs) 

select to_char(rec_trans_dt,'yyyymm') dt, svc_st, customer2 cust, a.acna, pon, prod_subcat
from naccprod.asr_volumes_details a, naccprod.ossams_acna_lkp b
where to_char(rec_trans_dt,'yyyymmdd') between '20120201' and '20120229'
and disc_ind = 'Y'
and svc_st not in ('IN','MI','NC','SC')
and pon not like '%ORBIT%'
and a.acna = b.acna
order by 1,2,3,4,6




select * from naccprod.asr_dim
where proj_ind like ' FTATTNSB3GWV%'