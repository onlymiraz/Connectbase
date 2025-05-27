CREATE TABLE [dbo].[TBL_CONTRACT_INFORMATION]
(
    [BANCARCD] varchar(10),
    [BTN] varchar(10),
    [STN] varchar(10),
    [WTN] varchar(10),
    [SUBLSN] varchar(20),
    [SUBFRN] varchar(20),
    [SUBCDT] numeric(8,0),
    [SUBDDT] numeric(8,0),
    [ADDRESS_LINE_1] varchar(250),
    [ADDRESS_LINE_2] varchar(250),
    [CITY] varchar(100),
    [STATE] varchar(2),
    [POSTAL_CODE] varchar(10),
    [CONTRACT_ID] bigint,
    [DESCRIPTION] varchar(250),
    [CONTRACT_TYPE] varchar(5),
    [OFFER_DATE] date,
    [EFFECTIVE_DATE] date,
    [EXPIRATION_DATE] date,
    [TERM] numeric(3,0),
    [STATUS] varchar(1)
)
