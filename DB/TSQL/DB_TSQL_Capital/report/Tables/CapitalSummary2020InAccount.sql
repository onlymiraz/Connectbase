CREATE TABLE [report].[CapitalSummary2020InAccount] (
    [ID]          INT          IDENTITY (1, 1) NOT NULL,
    [AccountID]   INT          NULL,
    [Title]       VARCHAR (50) NULL,
    [AccountLike] BIT          NULL,
    [Prime1]      VARCHAR (20) NULL,
    [Sub1]        VARCHAR (20) NULL,
    [Prime2]      VARCHAR (20) NULL,
    [Sub2]        VARCHAR (20) NULL,
    CONSTRAINT [PK_CapitalSummary2020InAccount] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CapitalSummary2020InAccount_AccountID]
    ON [report].[CapitalSummary2020InAccount]([AccountID] ASC);

