CREATE TABLE WCF.[TBL_REV_BY_PROD]
(
    [RPT_MTH] DATETIME2,
    [CUST_SEGMT] varchar(40),
    [NetworkCapability] nvarchar(17),
    [ProvisionedNetwork] varchar(14),
    [LINE_CARD_TYPE] varchar(5),
    [LINE_CARD_TYPE_DESC] varchar(30),
    [DWELLING_TYPE] varchar(3),
    [WIRECENTER] varchar(8),
    [F1_CABLE_STATUS] varchar(1),
    [WCF_PRD_TYPE] nvarchar(6),
    [LINES] int,
    [MRC] numeric(18,2),
    [BundleDesc] varchar(200),
    [VOICE_LINES] int,
    [DATA_LINES] int,
    UPDATE_DT DATE
)
