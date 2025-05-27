CREATE TABLE [forecast].[BudgetCategory] (
    [ID]             INT          IDENTITY (1, 1) NOT NULL,
    [BudgetCategory] VARCHAR (50) NOT NULL,
    [HasCarryIn]     BIT          NOT NULL,
    CONSTRAINT [PK__BudgetCa__3214EC27CA64320B] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ__BudgetCa__DFB09E1DC0D82EA5] UNIQUE NONCLUSTERED ([BudgetCategory] ASC)
);

