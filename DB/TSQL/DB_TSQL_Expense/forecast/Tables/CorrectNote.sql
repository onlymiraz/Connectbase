CREATE TABLE [forecast].[CorrectNote] (
    [ProjectNumber]    INT            NOT NULL,
    [SubprojectNumber] SMALLINT       NOT NULL,
    [AnalystNotes]     VARCHAR (4000) NULL,
    [CorrectNote]      VARCHAR (800)  NULL,
    [CreatedBy]        VARCHAR (20)   NULL,
    [LatestDate]       DATETIME       NULL
);

