CREATE TABLE [forecast].[SubprojectCIAC] (
    [ProjectNumber]    INT      NOT NULL,
    [SubprojectNumber] SMALLINT NOT NULL,
    [Budget]           MONEY    CONSTRAINT [DF_SubprojectCIAC_Budget] DEFAULT ((0)) NOT NULL,
    [Spend]            MONEY    CONSTRAINT [DF_SubprojectCIAC_Spend] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SubprojectCIAC] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC, [SubprojectNumber] ASC) WITH (PAD_INDEX = ON),
    CONSTRAINT [FK_SubprojectCIAC_Subproject] FOREIGN KEY ([ProjectNumber], [SubprojectNumber]) REFERENCES [forecast].[Subproject] ([ProjectNumber], [SubprojectNumber]) ON DELETE CASCADE
);


GO
ALTER TABLE [forecast].[SubprojectCIAC] NOCHECK CONSTRAINT [FK_SubprojectCIAC_Subproject];

