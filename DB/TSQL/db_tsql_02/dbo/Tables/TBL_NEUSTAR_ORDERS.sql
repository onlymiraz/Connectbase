CREATE TABLE [dbo].[TBL_NEUSTAR_ORDERS]
(
    [REPORT_RUN_DATE] date,
    [ENV] varchar(2),
    [ORDNO] varchar(9),
    [WTN] numeric(10,0),
    [BTN] numeric(10,0),
    [CUSTNM] varchar(30),
    [PON] varchar(20),
    [ORD_TYPE] nvarchar(8),
    [CCNA] varchar(4),
    [SERV_TYPE] varchar(2),
    [STAGE] varchar(3),
    [SO_ACT_COMP_DT] date
)
