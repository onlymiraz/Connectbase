CREATE TABLE [PushPull].[LZ_ListAvailProjects] (
    [ProjectNumber]     NVARCHAR (100) NULL,
    [Year]              NVARCHAR (100) NULL,
    [State]             NVARCHAR (100) NULL,
    [Region]            NVARCHAR (100) NULL,
    [Wirecenter]        NVARCHAR (MAX) NULL,
    [#CustLocations]    NVARCHAR (100) NULL,
    [CostperCustLoc]    NVARCHAR (100) NULL,
    [ProjectType]       NVARCHAR (100) NULL,
    [JustificationCode] NVARCHAR (100) NULL,
    [OriginalBudget]    NVARCHAR (100) NULL,
    [CurrBudget]        NVARCHAR (100) NULL,
    [ProjIRR]           NVARCHAR (100) NULL,
    [Remove?]           NVARCHAR (100) NULL
);

