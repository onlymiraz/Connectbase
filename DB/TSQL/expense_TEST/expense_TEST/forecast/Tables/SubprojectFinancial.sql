CREATE TABLE [forecast].[SubprojectFinancial] (
    [ProjectNumber]           INT      NOT NULL,
    [SubprojectNumber]        SMALLINT NOT NULL,
    [SpendingNotNeeded]       MONEY    CONSTRAINT [DF_SubprojectFinancial_SpendingNotNeeded] DEFAULT ((0)) NOT NULL,
    [AdditionalDollarsNeeded] MONEY    CONSTRAINT [DF_SubprojectFinancial_AdditionalDollarsNeeded] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SubprojectFinancial] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC, [SubprojectNumber] ASC) WITH (PAD_INDEX = ON),
    CONSTRAINT [FK_SubprojectFinancial_Subproject] FOREIGN KEY ([ProjectNumber], [SubprojectNumber]) REFERENCES [forecast].[Subproject] ([ProjectNumber], [SubprojectNumber]) ON DELETE CASCADE
);

