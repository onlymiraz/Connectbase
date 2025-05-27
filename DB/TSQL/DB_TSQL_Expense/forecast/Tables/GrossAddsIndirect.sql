CREATE TABLE [forecast].[GrossAddsIndirect] (
    [ProjectNumber]    INT      NOT NULL,
    [SubprojectNumber] SMALLINT NOT NULL,
    [Year]             SMALLINT NOT NULL,
    [January]          MONEY    CONSTRAINT [DF_GrossAddsIndirect_January] DEFAULT ((0)) NULL,
    [February]         MONEY    CONSTRAINT [DF_GrossAddsIndirect_February] DEFAULT ((0)) NULL,
    [March]            MONEY    CONSTRAINT [DF_GrossAddsIndirect_March] DEFAULT ((0)) NULL,
    [April]            MONEY    CONSTRAINT [DF_GrossAddsIndirect_April] DEFAULT ((0)) NULL,
    [May]              MONEY    CONSTRAINT [DF_GrossAddsIndirect_May] DEFAULT ((0)) NULL,
    [June]             MONEY    CONSTRAINT [DF_GrossAddsIndirect_June] DEFAULT ((0)) NULL,
    [July]             MONEY    CONSTRAINT [DF_GrossAddsIndirect_July] DEFAULT ((0)) NULL,
    [August]           MONEY    CONSTRAINT [DF_GrossAddsIndirect_August] DEFAULT ((0)) NULL,
    [September]        MONEY    CONSTRAINT [DF_GrossAddsIndirect_September] DEFAULT ((0)) NULL,
    [October]          MONEY    CONSTRAINT [DF_GrossAddsIndirect_October] DEFAULT ((0)) NULL,
    [November]         MONEY    CONSTRAINT [DF_GrossAddsIndirect_November] DEFAULT ((0)) NULL,
    [December]         MONEY    CONSTRAINT [DF_GrossAddsIndirect_December] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_GrossAddsIndirect] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC, [SubprojectNumber] ASC, [Year] ASC) WITH (PAD_INDEX = ON),
    CONSTRAINT [FK_GrossAddsIndirect_Project] FOREIGN KEY ([ProjectNumber]) REFERENCES [forecast].[Project] ([ProjectNumber]),
    CONSTRAINT [FK_GrossAddsIndirect_Subproject] FOREIGN KEY ([ProjectNumber], [SubprojectNumber]) REFERENCES [forecast].[Subproject] ([ProjectNumber], [SubprojectNumber]) ON DELETE CASCADE
);

