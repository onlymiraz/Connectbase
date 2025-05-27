CREATE TABLE [PushPull].[LZ_UnapprovedAvailProjSection] (
    [ProjectNumber]       NVARCHAR (100) NULL,
    [Year]                NVARCHAR (100) NULL,
    [State]               NVARCHAR (100) NULL,
    [Region]              NVARCHAR (100) NULL,
    [Wirecenter]          NVARCHAR (MAX) NULL,
    [CustomerLocation]    NVARCHAR (MAX) NULL,
    [CostPerCustLocation] NVARCHAR (100) NULL,
    [ProjectType]         NVARCHAR (100) NULL,
    [JustificationCode]   NVARCHAR (100) NULL,
    [OrigBudget]          NVARCHAR (100) NULL,
    [CurrBudget]          NVARCHAR (100) NULL,
    [ProjectIRR]          NVARCHAR (100) NULL
);

