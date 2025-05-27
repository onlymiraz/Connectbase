CREATE TABLE [forecast].[BudgetLine] (
    [BudgetLineNumber]      INT           NOT NULL,
    [BudgetLineName]        VARCHAR (100) NULL,
    [BudgetLineDescription] VARCHAR (200) NULL,
    CONSTRAINT [PK_budget_line] PRIMARY KEY CLUSTERED ([BudgetLineNumber] ASC)
);

