CREATE TABLE [forecast].[SummaryColumnGroup] (
    [ID]        INT          IDENTITY (1, 1) NOT NULL,
    [GroupName] VARCHAR (25) NOT NULL,
    [Order]     INT          NULL,
    CONSTRAINT [PK__SummaryC__3214EC27BC19C2ED] PRIMARY KEY CLUSTERED ([ID] ASC)
);

