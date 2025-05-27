CREATE TABLE [report].[CapitalSummary2020Category] (
    [CategoryID] INT           IDENTITY (1, 1) NOT NULL,
    [Category]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_CapitalSummary2020Category] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);

