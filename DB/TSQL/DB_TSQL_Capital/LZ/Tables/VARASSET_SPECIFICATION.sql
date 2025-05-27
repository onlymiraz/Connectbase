CREATE TABLE [LZ].[VARASSET_SPECIFICATION] (
    [Id]                  NVARCHAR (50)  NULL,
    [RowVersion]          NVARCHAR (50)  NULL,
    [CreatedBy]           NVARCHAR (50)  NULL,
    [CreatedOn]           NVARCHAR (26)  NULL,
    [UpdatedBy]           NVARCHAR (50)  NULL,
    [UpdatedOn]           NVARCHAR (26)  NULL,
    [Name]                NVARCHAR (30)  NULL,
    [Instance_InstanceId] NVARCHAR (50)  NULL,
    [Instance_EntityId]   NVARCHAR (50)  NULL,
    [Attribute]           NVARCHAR (50)  NULL,
    [StringValue]         NVARCHAR (100) NULL,
    [IntegerValue]        NVARCHAR (10)  NULL,
    [DecimalValue]        NVARCHAR (18)  NULL,
    [BooleanValue]        NVARCHAR (10)  NULL,
    [PicklistValue]       NVARCHAR (50)  NULL,
    [DataType]            NVARCHAR (50)  NULL,
    [InstanceValue]       NVARCHAR (50)  NULL,
    [InstanceValueEntity] NVARCHAR (50)  NULL,
    [DateValue]           NVARCHAR (26)  NULL,
    [DateTimeValue]       NVARCHAR (26)  NULL
);

