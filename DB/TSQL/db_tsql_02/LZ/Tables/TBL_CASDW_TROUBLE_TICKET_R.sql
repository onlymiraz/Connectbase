CREATE TABLE LZ.[TBL_CASDW_TROUBLE_TICKET_R]
(
    [ACNA] varchar(3),
    [TICKET_ID] varchar(15),
    [FLD_COMPLETE_REPAIRCODE] varchar(255),
    [FLD_ASSIGNMENTPROFILE] varchar(30),
    [FLD_REQUESTSTATUS] varchar(50),
    [FLD_REQUESTTYPE] varchar(69),
    [FLD_STARTDATE] datetime,
    [FLD_EVENT_END_TIME] datetime,
    [DTE_CLOSEDDATETIME] datetime,
    [FLD_MODIFIEDDATE] datetime,
    [EXCHANGE_CARRIER_CIRCUIT_ID] varchar(255),
    [FLD_TROUBLEREPORTSTATE] varchar(255)
)
