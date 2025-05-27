CREATE TABLE [ProjApproval].[PostSale_DSAT_History] (
    [Opportunity ID]               VARCHAR (50)  NULL,
    [STATE]                        VARCHAR (5)   NULL,
    [PROJECT]                      INT           NULL,
    [SUB-PROJECT]                  SMALLINT      NULL,
    [CIAC]                         MONEY         NULL,
    [PREQUAL TYPE]                 VARCHAR (10)  NULL,
    [PREQUAL # (BDT/DSAT)]         VARCHAR (15)  NULL,
    [DSAT Lit Building?]           VARCHAR (5)   NULL,
    [ORDER # (STATS SF ASR)]       VARCHAR (50)  NULL,
    [CUST NAME]                    VARCHAR (100) NULL,
    [DSAT TIERS]                   VARCHAR (10)  NULL,
    [DSAT BW]                      VARCHAR (30)  NULL,
    [PREQUAL $ (BDT/DSAT)]         MONEY         NULL,
    [BDT YR APPRVD]                INT           NULL,
    [RETAIL OR CARRIER]            VARCHAR (25)  NULL,
    [TERM Months]                  INT           NULL,
    [MRC]                          MONEY         NULL,
    [NRC]                          MONEY         NULL,
    [Contract Signature ASR Order] DATETIME      NULL,
    [VARASSET TICKET]              VARCHAR (15)  NULL,
    [NOTES]                        VARCHAR (MAX) NULL
);

