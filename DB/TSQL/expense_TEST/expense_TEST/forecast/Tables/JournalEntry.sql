CREATE TABLE [forecast].[JournalEntry] (
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [Type]          TINYINT       NOT NULL,
    [ProjectNumber] INT           NULL,
    [Company]       INT           NULL,
    [OperatingArea] INT           NULL,
    [MainAccount]   INT           NULL,
    [SubAccount]    INT           NULL,
    [CostCode]      INT           NULL,
    [Description]   VARCHAR (200) NULL,
    [Amount]        MONEY         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

