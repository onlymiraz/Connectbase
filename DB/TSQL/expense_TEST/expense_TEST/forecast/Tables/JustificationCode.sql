CREATE TABLE [forecast].[JustificationCode] (
    [JustificationCode]   TINYINT      NOT NULL,
    [JustificationTitle]  VARCHAR (50) NULL,
    [FunctionalGroup]     NCHAR (1)    NULL,
    [BudgetCategory]      VARCHAR (50) NULL,
    [BudgetCategoryID]    INT          NULL,
    [SubBudgetCategoryID] INT          NULL,
    CONSTRAINT [PK_JustificationCode] PRIMARY KEY CLUSTERED ([JustificationCode] ASC)
);

