CREATE TABLE [forecast].[Exchange] (
    [ExchangeNumber] INT           NOT NULL,
    [ExchangeName]   VARCHAR (100) NULL,
    [State]          CHAR (2)      NULL,
    [Region]         CHAR (8)      NULL,
    [Company]        SMALLINT      NULL,
    [OperatingArea]  SMALLINT      NULL,
    CONSTRAINT [PK_exchange_list] PRIMARY KEY CLUSTERED ([ExchangeNumber] ASC)
);

