CREATE TABLE [Brownfield].[ForecastExportPriorYearsSpendUpdate] (
    [ProjectNumber]                NVARCHAR (10) NULL,
    [SubprojectNumber]             NVARCHAR (10) NULL,
    [JustificationCode]            NVARCHAR (10) NULL,
    [GrossAddsTotal]               MONEY         NULL,
    [PriorYearsSpendTotal]         MONEY         NULL,
    [PriorYearsSpendDirectFinal]   MONEY         NULL,
    [PriorYearsSpendIndirectFinal] MONEY         NULL,
    [PriorYearsSpendTotalFinal]    MONEY         NULL,
    [EndingGrossAddsTotal]         MONEY         NULL,
    [ProductionDate]               DATE          NULL
);

