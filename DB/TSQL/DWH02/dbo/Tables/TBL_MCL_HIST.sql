CREATE TABLE [dbo].[TBL_MCL_HIST] (
    [SECONDARY_ID_SOURCE]  NVARCHAR (255) NULL,
    [PRIMARY_ID_SOURCE]    NVARCHAR (255) NULL,
    [PRIMARY_ID]           NVARCHAR (255) NULL,
    [PRIMARY_CARRIER_NM]   NVARCHAR (255) NULL,
    [PRIMARY_FOCUS]        NVARCHAR (255) NULL,
    [ID_TYPE]              NVARCHAR (255) NULL,
    [SECONDARY_ID]         NVARCHAR (255) NULL,
    [SECONDARY_CARRIER_NM] NVARCHAR (255) NULL,
    [VP]                   NVARCHAR (255) NULL,
    [Column1]              NVARCHAR (255) NULL,
    [SLS_DIR]              NVARCHAR (255) NULL,
    [AE_SR]                NVARCHAR (255) NULL,
    [AE_2]                 NVARCHAR (255) NULL,
    [AE]                   NVARCHAR (255) NULL,
    [SLS_ENGR]             NVARCHAR (255) NULL,
    [CHECK]                NVARCHAR (255) NULL,
    [UPDATE_DT]            DATETIME       NULL,
    [UPLOAD_TS]            DATETIME       NOT NULL
);

