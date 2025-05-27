CREATE TABLE [report].[CapitalSummary2020InJustificationCode] (
    [ID]                INT          NOT NULL,
    [Title]             VARCHAR (50) NULL,
    [JustificationCode] INT          NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CapitalSummary2020InJustificationCode]
    ON [report].[CapitalSummary2020InJustificationCode]([ID] ASC, [JustificationCode] ASC);

