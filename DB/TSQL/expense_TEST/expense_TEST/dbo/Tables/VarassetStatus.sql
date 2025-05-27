CREATE TABLE [dbo].[VarassetStatus] (
    [ProjectNumber]               INT           NULL,
    [SubprojectNumber]            SMALLINT      NULL,
    [VarassetStatus]              VARCHAR (100) NULL,
    [VarassetStatusModifiedDate]  DATE          NULL,
    [VarassetClosingIssue]        VARCHAR (100) NULL,
    [VarassetScheduledFinishDate] DATE          NULL,
    [VarassetWorkOrderStatus]     VARCHAR (50)  NULL
);

