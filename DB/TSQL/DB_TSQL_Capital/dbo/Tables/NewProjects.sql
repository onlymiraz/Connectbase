CREATE TABLE [dbo].[NewProjects] (
    [ProjectNumber]    INT      NOT NULL,
    [SubprojectNumber] SMALLINT NOT NULL,
    CONSTRAINT [PK_NewProjects] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC, [SubprojectNumber] ASC)
);

