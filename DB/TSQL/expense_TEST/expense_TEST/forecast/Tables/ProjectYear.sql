CREATE TABLE [forecast].[ProjectYear] (
    [ProjectNumber] NCHAR (7) NOT NULL,
    [Year]          INT       NULL,
    CONSTRAINT [PK_ProjectYear] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC)
);

