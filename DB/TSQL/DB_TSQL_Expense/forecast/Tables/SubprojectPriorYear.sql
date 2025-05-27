CREATE TABLE [forecast].[SubprojectPriorYear] (
    [ProjectNumber]    INT      NOT NULL,
    [SubprojectNumber] SMALLINT NOT NULL,
    [Spend]            MONEY    CONSTRAINT [DF_SubprojectPriorYear_Spend] DEFAULT ((0)) NOT NULL,
    [Direct]           MONEY    NULL,
    [Indirect]         MONEY    NULL,
    CONSTRAINT [PK_SubprojectPriorYear] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC, [SubprojectNumber] ASC) WITH (PAD_INDEX = ON),
    CONSTRAINT [FK_SubprojectPriorYear_Subproject] FOREIGN KEY ([ProjectNumber], [SubprojectNumber]) REFERENCES [forecast].[Subproject] ([ProjectNumber], [SubprojectNumber]) ON DELETE CASCADE
);

