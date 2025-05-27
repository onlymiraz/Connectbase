select dw_state, dw_company, mnth, '6 Billing' cat, metric, descr, prod, sum(num) num, sum(denom) den, round(sum(num)/sum(denom)*100,2) result        
from (        
--        
SELECT 'BI-8-01-2000' metric, 'Non-Recurring Charge Completeness' descr, 'Resale' prod, 
       dw_state, dw_company, substr(DW_RPT_MON_YEAR,1,2)||'/01/'||substr(DW_RPT_MON_YEAR,3,4) mnth,
       case when nrc_amt_blprd>nrc_amt then nrc_amt when nrc_amt-nrc_amt_blprd >25 then nrc_amt                                                  
        else nrc_amt_blprd end num, nrc_amt denom                        
FROM camp.VW_BI_8_01_2000_F13         
  WHERE BILLING_SUMMARY_TYPE IN ('R','S','T','U') AND SRC_SYS = 'DPI'        
  and dw_state in ('OR','WA') 
  and nrc_amt >0
  and  DW_RPT_MON_YEAR ='042020'  --MUST CHANGE THIS DATE EACH MONTH 
--
UNION ALL
--
SELECT 'BI-8-01-3000' metric, 'Non-Recurring Charge Completeness' descr, 'UNE' prod, 
       dw_state, dw_company, substr(DW_RPT_MON_YEAR,1,2)||'/01/'||substr(DW_RPT_MON_YEAR,3,4) mnth,
       case when nrc_amt_blprd>nrc_amt then nrc_amt when nrc_amt-nrc_amt_blprd >25 then nrc_amt                        
        else nrc_amt_blprd end num, nrc_amt denom                        
FROM camp.VW_BI_8_01_2000_F13         
  WHERE BILLING_SUMMARY_TYPE IN ('L','M','N','O') AND SRC_SYS = 'DPI'         
  and dw_state in ('OR','WA') 
  and nrc_amt >0
  and  DW_RPT_MON_YEAR ='042020'  --MUST CHANGE THIS DATE EACH MONTH            
--        
)        
group by dw_state, dw_company, mnth, metric, descr, prod        
order by dw_state, dw_company, metric;        


		
