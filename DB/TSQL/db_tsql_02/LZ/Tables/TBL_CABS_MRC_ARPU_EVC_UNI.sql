CREATE TABLE LZ.[TBL_CABS_MRC_ARPU_EVC_UNI]
(
    [RESULTS_THROUGH] date,
    [BILL_MONTH_DT] date,
    [WIRELESS] nvarchar(8),
    [TOP_CUST] varchar(37),
    [PRIMARY_CARRIER_NAME] nvarchar(100),
    [PRODUCT] nvarchar(50),
    [STATE] varchar(5),
    [SVC_GROUP] nvarchar(3),
    [MRC_ALL_BILLED] numeric(18,2),
    [COUNT_ALL_BILLED] numeric(15,2),
    [ARPU_ALL_BILLED] numeric(18,2),
    [MRC_FIRST_BILL] numeric(18,2),
    [COUNT_FIRST_BILL] numeric(15,2),
    [ARPU_FIRST_BILL] numeric(18,2),
    [MRC_LAST_BILL] numeric(18,2),
    [COUNT_LAST_BILL] numeric(15,2),
    [ARPU_LAST_BILL] numeric(18,2)
)
