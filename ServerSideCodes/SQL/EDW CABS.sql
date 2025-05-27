
select * --distinct circuit_no, acna, ixc_name, state_cd
from edw_vwmc.cabs_spcl_accs_bill_rev_dtl_v
--where BILL_MONTH_DT = '2016-04-01'
--and substr(circuit_no,1,7) in ('69.HFFU','69.HCFU')
where circuit_no like '81.HCFU.98101%'
order by 1;

select * 
from edw_vwmc.cabs_bill_rev_acct_detail_v
--where BILL_MONTH_DT = '2016-04-01';
where circuit_no like '81.HCFU.940151%';

