select * --distinct circuit_no, plan_id
from EDW_VWMC.CABS_SPCL_ACCS_BILL_REV_DTL_V
where bill_month_dt = '2022-06-01' 
and substr(circuit_no,1,14) in (
'11.KQGN.775316')
;

