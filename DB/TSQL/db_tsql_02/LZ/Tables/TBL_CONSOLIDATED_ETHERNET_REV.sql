CREATE TABLE [LZ].[TBL_CONSOLIDATED_ETHERNET_REV] (
    [GL_CMPY_NO] varchar(3),
    [CUST_NM] varchar(50),
    [ACCT_BTN] varchar(10),
    [CUST_NO] varchar(10),
    [PRD_SVC_CD] varchar(10),
    [BILL_MONTH] date,
    [PRC_SVC_CD_DS] varchar(250),
    [DIRECT_SALES_REV_TYPE_CD] smallint,
    [TOTAL_BILL_AMT_NET] numeric(18,2),
    [GL_MATRIX_NO] nvarchar(5)
)
