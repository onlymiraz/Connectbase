CREATE TABLE [ProjApproval].[FF] (
    [ProjectNumber]      INT           NOT NULL,
    [SubprojectNumber]   SMALLINT      NOT NULL,
    [ClassOfPlant]       CHAR (2)      NULL,
    [LinkCode]           VARCHAR (25)  NULL,
    [ProjectDescription] VARCHAR (200) NULL,
    [BudgetCategory]     VARCHAR (112) NULL,
    [JustificationCode]  TINYINT       NULL,
    [ProjectStatusCode]  CHAR (2)      NULL,
    [ApprovalDate]       DATE          NULL,
    [CloseDate]          DATE          NULL,
    [productiondate]     DATE          NULL
);

