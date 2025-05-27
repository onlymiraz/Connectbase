CREATE TABLE [report].[CapitalSummary2020Criteria] (
    [CriteriaID]            INT          IDENTITY (1, 1) NOT NULL,
    [CategoryID]            INT          NULL,
    [Title]                 VARCHAR (50) NULL,
    [InJustificationCodeID] INT          NULL,
    [InJustificationCode]   VARCHAR (50) NULL,
    [InAccountID]           INT          NULL,
    [InState]               VARCHAR (50) NULL,
    [BudgetCategoryID]      INT          NULL,
    [SubBudgetCategoryID]   INT          NULL,
    [LinkCode]              VARCHAR (20) NULL,
    [InFunctionalGroup]     VARCHAR (20) NULL,
    CONSTRAINT [PK_CapitalSummary2020Criteria] PRIMARY KEY CLUSTERED ([CriteriaID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020Criteria_InJustificationID]
    ON [report].[CapitalSummary2020Criteria]([InJustificationCodeID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020Criteria_InAccountID]
    ON [report].[CapitalSummary2020Criteria]([InAccountID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020Criteria_BudgetCategoryID]
    ON [report].[CapitalSummary2020Criteria]([BudgetCategoryID] ASC, [SubBudgetCategoryID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020Critera_InAccountID]
    ON [report].[CapitalSummary2020Criteria]([InAccountID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020Critera_InJustificationCode]
    ON [report].[CapitalSummary2020Criteria]([InJustificationCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020Critera_CategoryID]
    ON [report].[CapitalSummary2020Criteria]([CategoryID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020Critera_LinkCode]
    ON [report].[CapitalSummary2020Criteria]([LinkCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020Critera_InFunctionalGroup]
    ON [report].[CapitalSummary2020Criteria]([InFunctionalGroup] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020Criteria_LinkCode]
    ON [report].[CapitalSummary2020Criteria]([LinkCode] ASC);

