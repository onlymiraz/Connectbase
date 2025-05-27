
select count(*)
from naccprod.asr_volumes_details
where to_char(rec_trans_dt,'yyyymmdd') between '20120219' and '20120225'
