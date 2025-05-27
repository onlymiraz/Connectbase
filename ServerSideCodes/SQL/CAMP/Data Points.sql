--Benchmark  
select state, metric, month, clec_agg_num NUM, clec_agg_denom DEN, clec_agg_result RES, ((benchmark-clec_agg_result)*clec_agg_denom)/100 DP
from camp.fcc_aggr_rpt
where state = 'OH'
--and to_char(month,'yyyymm') = '201204'
--and clec_agg_denom > 0 and clec_agg_result < 95
and metric like 'OR-2-04-3555%'
order by 2,3




--Parity Percentage  (Lower is Better)  
Select state, metric, month, clec_agg_num NUM, clec_agg_denom DEN, clec_agg_result RES, ILEC_AGG_NUM, ILEC_AGG_DENOM, ILEC_AGG_RESULT, Z_SCORE,
       ABS(((((ILEC_AGG_RESULT/100)-(-1.645*(SQRT(((ILEC_AGG_RESULT/100)*(1-(ILEC_AGG_RESULT/100)))*(1/CLEC_AGG_DENOM+1/ILEC_AGG_DENOM)))))*100)-CLEC_AGG_RESULT)/100)*CLEC_AGG_DENOM  dp
from camp.fcc_aggr_rpt
where state = 'OH'
--and to_char(month,'yyyymm') = '201204'
and z_score < -1.645
and metric like 'MR-2-01-2100%'



--Parity Percentage  (PR-3 - HIB )  
Select state, metric, month, clec_agg_num NUM, clec_agg_denom DEN, clec_agg_result RES, ILEC_AGG_RESULT, Z_SCORE,
       ABS(((((ILEC_AGG_RESULT/100)+(-1.645*(SQRT(((ILEC_AGG_RESULT/100)*(1-(ILEC_AGG_RESULT/100)))*(1/CLEC_AGG_DENOM+1/ILEC_AGG_DENOM)))))*100)-CLEC_AGG_RESULT)/100)*CLEC_AGG_DENOM  dp
from camp.fcc_aggr_rpt
where state = 'OH'
--and to_char(month,'yyyymm') = '201204'
and z_score < -1.645
and metric like 'PR-3-08-2100%'





--Parity Average  
select state, metric, month, clec_agg_num NUM, clec_agg_denom DEN, clec_agg_result RES, Z_SCORE, ILEC_STANDARD_DEV, 
       ABS(CLEC_AGG_RESULT/(ILEC_AGG_RESULT-(-1.645*(SQRT((ILEC_STANDARD_DEV*ILEC_STANDARD_DEV)*((1/CLEC_AGG_DENOM)+(1/ILEC_AGG_DENOM))))))-1)*CLEC_AGG_DENOM dp   
from camp.fcc_aggr_rpt
where state = 'NV'
and to_char(month,'yyyymm') = '201205'
and metric like 'MR-4-01-3220%'





select * from camp.fcc_aggr_rpt
where state = 'OH'
--and to_char(month,'yyyymm') = '201204'
and metric like 'PR-3-08-2100%'