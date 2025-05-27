CREATE TABLE [forecast].[Project] (
    [ProjectNumber]       INT           NOT NULL,
    [ProjectDescription]  VARCHAR (200) NULL,
    [ClassOfPlant]        CHAR (2)      NULL,
    [LinkCode]            VARCHAR (25)  NULL,
    [JustificationCode]   TINYINT       NULL,
    [BudgetCategoryID]    INT           NULL,
    [SubBudgetCategoryID] INT           NULL,
    [FunctionalGroup]     CHAR (1)      NULL,
    [ApprovalCode]        CHAR (2)      NULL,
    [ProjectType]         CHAR (1)      NULL,
    [Billable]            CHAR (1)      NULL,
    [Company]             SMALLINT      NULL,
    [ExchangeName]        VARCHAR (50)  NULL,
    [OperatingArea]       SMALLINT      NULL,
    [State]               CHAR (2)      NULL,
    [Engineer]            VARCHAR (50)  NULL,
    [ProjectOwner]        VARCHAR (50)  NULL,
    [AssignedTo]          INT           NULL,
    CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC) WITH (PAD_INDEX = ON)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Project_ProjectNumber_Included]
    ON [forecast].[Project]([ProjectNumber] ASC)
    INCLUDE([LinkCode], [JustificationCode], [BudgetCategoryID], [SubBudgetCategoryID]);


GO
CREATE NONCLUSTERED INDEX [IX__Project_LinkCode]
    ON [forecast].[Project]([LinkCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX__Project_FunctionalGroup]
    ON [forecast].[Project]([FunctionalGroup] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Project_BudgetCategoryID]
    ON [forecast].[Project]([BudgetCategoryID] ASC, [SubBudgetCategoryID] ASC) WITH (PAD_INDEX = ON);

