CREATE TABLE [forecast].[SubBudgetCategory] (
    [ID]                INT          IDENTITY (1, 1) NOT NULL,
    [MainID]            INT          NOT NULL,
    [SubBudgetCategory] VARCHAR (50) NOT NULL,
    [HasCarryIn]        BIT          NOT NULL,
    [Separator]         CHAR (1)     NULL,
    [Overwrite]         BIT          NOT NULL,
    CONSTRAINT [PK_SubBudgetCategory] PRIMARY KEY CLUSTERED ([ID] ASC)
);

