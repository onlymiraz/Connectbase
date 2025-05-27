CREATE TABLE [forecast].[SubprojectFutureYear] (
    [ProjectNumber]    INT      NOT NULL,
    [SubprojectNumber] SMALLINT NOT NULL,
    [SpendInfinium]    MONEY    CONSTRAINT [DF_SubprojectFutureYear_SpendInfinium] DEFAULT ((0)) NOT NULL,
    [Spend]            MONEY    CONSTRAINT [DF_SubprojectFutureYear_Spend] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SubprojectFutureYear] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC, [SubprojectNumber] ASC) WITH (PAD_INDEX = ON),
    CONSTRAINT [FK_SubprojectFutureYear_Subproject] FOREIGN KEY ([ProjectNumber], [SubprojectNumber]) REFERENCES [forecast].[Subproject] ([ProjectNumber], [SubprojectNumber]) ON DELETE CASCADE
);

