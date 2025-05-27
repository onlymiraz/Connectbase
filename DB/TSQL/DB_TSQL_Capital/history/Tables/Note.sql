CREATE TABLE [history].[Note] (
    [ProjectNumber]    INT           NOT NULL,
    [SubprojectNumber] SMALLINT      NULL,
    [Text]             VARCHAR (MAX) NULL,
    [CreatedBy]        VARCHAR (20)  NULL,
    [CreatedDate]      DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [myindex2]
    ON [history].[Note]([ProjectNumber] ASC);

