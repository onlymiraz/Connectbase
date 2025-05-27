CREATE TABLE LZ.[TBL_MTTR]
(
    [TICKET_ID] varchar(25),
    [STATE] varchar(2),
    [REGION] varchar(10),
    [CLEC_ID] varchar(10),
    [CKT_ID] varchar(255),
    [PRODUCT] varchar(10),
    [PROD2] varchar(10),
    [BDW] varchar(10),
    [CREATE_DATE] datetime,
    [CLEARED_DT] datetime,
    [CLOSED_DT] datetime,
    [TTR] float,
    [REPAIR_CODE] varchar(255),
    [DISP] varchar(255),
    [CABLE_CUT] varchar(255),
    [FOUND] varchar(1),
    [CAUSE_CD] varchar(255),
    [MON] varchar(2)
)
