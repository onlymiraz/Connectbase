select DM_LSR_STATE_CD State, DM_LSR_CCNA_CD CCNA, DM_LSR_ORD_CREATE_DT Create_Dt, DM_LSR_DUE_DT, DM_LSR_BILL_EFCTV_DT Bill_Effect_Dt, 
       DM_LSR_SIMPLE_PORT_IND Simple_Port, 
       DM_LSR_CUST_REQ_CD Cust_Req,	DM_LSR_DAYS_TO_INSTALL Days_to_Install,	DM_LSR_DELAY_DAYS Delay_Days,		DM_LSR_BILL_TN TN


select DM_LSR_SIMPLE_PORT_IND, sum(DM_LSR_DAYS_TO_INSTALL) num, count(*) den, sum(DM_LSR_DAYS_TO_INSTALL)/count(*) res
from DM_WST_FMART.NMPW_DM_PR_LSR_PRODUCT LSR
WHERE LSR.DM_LSR_RPTG_MONTH = '201107'
and	DM_LSR_CCNA_CD <> '#GT'
and	DM_LSR_CCNA_CD <> '#NU'
and dm_lsr_state_cd = 'MI'
and dm_lsr_subclass_cd1 = 'LNP'
and DM_LSR_REP_MONTH_CD = '1'
and DM_LSR_C2C_FCC_CD = 'FCC' 
and DM_LSR_ORD_STATUS_CD = 5
 and DM_LSR_DAYS_TO_INSTALL is not null
 and (DM_LSR_CREATE_LTERM <> DM_LSR_CMP_LTERM
 or (DM_LSR_CMP_LTERM is null
 and DM_LSR_CREATE_LTERM is not null)
 or (DM_LSR_CMP_LTERM is not null
 and DM_LSR_CREATE_LTERM is null))
 and (DM_LSR_BILL_TYPE_CD <> 'G'
 or DM_LSR_BILL_TYPE_CD is null)
 and DM_LSR_CMP_DT >=  DM_LSR_ORD_CREATE_DT
 and (DM_LSR_CUST_REQ_CD is null
  or (DM_LSR_CUST_REQ_CD = 'G' and DM_LSR_DAYS_TO_INSTALL <= 5))
group by   DM_LSR_SIMPLE_PORT_IND


