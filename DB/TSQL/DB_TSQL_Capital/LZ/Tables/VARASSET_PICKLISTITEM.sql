CREATE TABLE [LZ].[VARASSET_PICKLISTITEM] (
    [Id]             NVARCHAR (50)  NOT NULL,
    [RowVersion]     NVARCHAR (50)  NULL,
    [CreatedBy]      NVARCHAR (50)  NULL,
    [CreatedOn]      NVARCHAR (26)  NULL,
    [UpdatedBy]      NVARCHAR (50)  NULL,
    [UpdatedOn]      NVARCHAR (26)  NULL,
    [SMState]        NVARCHAR (50)  NULL,
    [SMReason]       NVARCHAR (50)  NULL,
    [PicklistParent] NVARCHAR (50)  NULL,
    [Name]           NVARCHAR (100) NULL,
    [Code]           NVARCHAR (30)  NULL,
    [Description]    NVARCHAR (100) NULL,
    [SortOrder]      NVARCHAR (10)  NULL,
    [IsActive]       NVARCHAR (10)  NULL,
    [PicklistType]   NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

