CREATE TABLE [LZ].[TBL_CABS_SHORTCUT] (
    [CLEAN_ID]             VARCHAR (30) NOT NULL,
    [BILL_MONTH_DT]        DATE         NOT NULL,
    [LAST_BILL_MONTH_DT]   DATE         NULL,
    [PRIMARY_CARRIER_NAME] VARCHAR (75) NOT NULL,
    [PRODUCT]              VARCHAR (50) NOT NULL,
    [SVC_GROUP]            CHAR (10)    NOT NULL,
    [TIER]                 INT          NULL,
    [TOTAL_MRC]            FLOAT (53)   NOT NULL,
    [UNI_MBPS]             INT          NULL,
    [EVC_MBPS]             INT          NULL,
    PRIMARY KEY CLUSTERED ([CLEAN_ID] ASC)
);

