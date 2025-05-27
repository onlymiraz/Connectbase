
--CDD 


select distinct a.asr_id, a.d_rec, a.dd, a.status, a.svc_st state, 
    case when a.svc_st in ('WA','CA','OR') then 'West'
	     when a.svc_st in ('IL','OH') then 'Central'
		 else 'National' end region,
	a.order_comp_dt
from naccprod.cddd_wb_details a, naccprod.asr_dim b
where a.asr_id = b.asr_id 
and to_char(a.comp_dt,'yyyymmdd') between '20120219' and '20120225' 
and a.prod <> 'SWITCHED'
and a.svc_st in ('OR', 'WA', 'ID', 'NV', 'AZ', 'CA', 'OH', 'WI', 'IL')
  and a.measure_id = '281'
  

