CREATE TABLE [forecast].[SummaryColumn] (
    [ColumnName] VARCHAR (50) NOT NULL,
    [Alias]      VARCHAR (50) NULL,
    [GroupID]    INT          NULL,
    [Group]      VARCHAR (20) NULL,
    CONSTRAINT [PK__SummaryC__AE2C0983AF3F4DEA] PRIMARY KEY CLUSTERED ([ColumnName] ASC)
);

