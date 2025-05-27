CREATE TABLE [forecast].[SubprojectAuthorized] (
    [ProjectNumber]    INT      NOT NULL,
    [SubprojectNumber] SMALLINT NOT NULL,
    [Direct]           MONEY    CONSTRAINT [DF_SubprojectAuthorized_Direct] DEFAULT ((0)) NOT NULL,
    [Indirect]         MONEY    CONSTRAINT [DF_SubprojectAuthorized_Indirect] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SubprojectAuthorized] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC, [SubprojectNumber] ASC) WITH (PAD_INDEX = ON),
    CONSTRAINT [FK_SubprojectAuthorized_Subproject] FOREIGN KEY ([ProjectNumber], [SubprojectNumber]) REFERENCES [forecast].[Subproject] ([ProjectNumber], [SubprojectNumber]) ON DELETE CASCADE
);

