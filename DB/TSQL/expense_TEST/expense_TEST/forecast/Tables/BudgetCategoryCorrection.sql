CREATE TABLE [forecast].[BudgetCategoryCorrection] (
    [ID]                  INT          IDENTITY (1, 1) NOT NULL,
    [BudgetCategoryID]    INT          NOT NULL,
    [SubBudgetCategoryID] INT          NULL,
    [ProjectNumber]       INT          NULL,
    [JustificationCode]   TINYINT      NULL,
    [FunctionalGroup]     CHAR (1)     NULL,
    [BudgetLineNumber]    INT          NULL,
    [LinkCode]            VARCHAR (25) NULL,
    [ClassOfPlant]        CHAR (2)     NULL,
    CONSTRAINT [PK_BudgetCategoryCorrection] PRIMARY KEY CLUSTERED ([ID] ASC)
);

