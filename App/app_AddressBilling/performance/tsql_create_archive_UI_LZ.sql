USE [Playground];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'UI_LZ_Archive'
      AND SCHEMA_NAME(schema_id) = 'addressbilling'
)
BEGIN
    CREATE TABLE [addressbilling].[UI_LZ_Archive](
        [ID]                 [int] IDENTITY(1,1) NOT NULL,
        [user_def_row_ID]    [nvarchar](100) NULL,
        [Address1]           [nvarchar](255) NOT NULL,
        [Address2]           [nvarchar](255) NULL,
        [City]               [nvarchar](255) NOT NULL,
        [Zip]                [nvarchar](255) NOT NULL,
        [State]              [nvarchar](255) NOT NULL,
        [Country]            [nvarchar](255) NULL,
        [DtmStamp]           [datetime] NULL,
        [ingestion_timestamp][datetime] NULL,
        [user_name]          [nvarchar](255) NULL,
        [user_corp]          [nvarchar](50) NULL,
        [batch_id]           [uniqueidentifier] NOT NULL,
        [user_email]         [nvarchar](255) NULL,
        [process_status]     [nvarchar](50) NULL,
     CONSTRAINT [PK_addressbilling.UI_LZ_Archive] PRIMARY KEY CLUSTERED 
     (
        [ID] ASC
     ) WITH (
        PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
        IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
        ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
     ) ON [PRIMARY]
    ) ON [PRIMARY];

    ALTER TABLE [addressbilling].[UI_LZ_Archive]
    ADD CONSTRAINT [DF_UI_LZ_Archive_ingestion_timestamp]
        DEFAULT (getdate()) FOR [ingestion_timestamp];

    ALTER TABLE [addressbilling].[UI_LZ_Archive]
    ADD DEFAULT (newid()) FOR [batch_id];

    ALTER TABLE [addressbilling].[UI_LZ_Archive]
    ADD CONSTRAINT [DF_UI_LZ_Archive_process_status]
        DEFAULT ('done') FOR [process_status];

    PRINT 'UI_LZ_Archive created';
END
ELSE
BEGIN
    PRINT 'UI_LZ_Archive table already exists.';
END;
GO
