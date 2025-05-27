CREATE TABLE [history].[Note] (
    [ProjectNumber]    INT           NOT NULL,
    [SubprojectNumber] SMALLINT      NULL,
    [Text]             VARCHAR (MAX) NULL,
    [CreatedBy]        VARCHAR (20)  NULL,
    [CreatedDate]      DATETIME      NULL
);

