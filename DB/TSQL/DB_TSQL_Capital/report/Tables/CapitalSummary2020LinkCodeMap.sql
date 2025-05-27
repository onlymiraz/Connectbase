CREATE TABLE [report].[CapitalSummary2020LinkCodeMap] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [LinkCodeFrom] VARCHAR (20) NULL,
    [LinkCodeTo]   VARCHAR (20) NOT NULL,
    CONSTRAINT [PK__CapitalS__3214EC27D87C3819] PRIMARY KEY CLUSTERED ([ID] ASC)
);

