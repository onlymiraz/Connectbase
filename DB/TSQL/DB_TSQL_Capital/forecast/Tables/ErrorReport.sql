CREATE TABLE [forecast].[ErrorReport] (
    [ProjectNumber]    NCHAR (7)      NOT NULL,
    [SubprojectNumber] NVARCHAR (3)   NULL,
    [ErrorType]        NVARCHAR (50)  NULL,
    [ErrorDescription] NVARCHAR (200) NULL,
    [ColumnName1]      NVARCHAR (50)  NULL,
    [ColumnValue1]     NVARCHAR (100) NULL,
    [ColumnName2]      NVARCHAR (50)  NULL,
    [ColumnValue2]     NVARCHAR (100) NULL,
    [ColumnName3]      NVARCHAR (50)  NULL,
    [ColumnValue3]     NVARCHAR (100) NULL
);

