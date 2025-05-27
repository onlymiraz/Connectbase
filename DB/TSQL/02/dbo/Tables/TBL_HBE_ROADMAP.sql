CREATE TABLE [dbo].[TBL_HBE_ROADMAP] (
    [STATE]             NVARCHAR (255) NULL,
    [WC_CLLI]           NVARCHAR (255) NOT NULL,
    [LATA]              NVARCHAR (255) NULL,
    [STATUS]            NVARCHAR (255) NULL,
    [SERVICES]          NVARCHAR (255) NULL,
    [QTR]               NVARCHAR (255) NULL,
    [YEAR]              NVARCHAR (255) NULL,
    [DEPLOYMENT_LOCKED] FLOAT (53)     NULL,
    [INSERT_TS]         DATETIME       NOT NULL
);

