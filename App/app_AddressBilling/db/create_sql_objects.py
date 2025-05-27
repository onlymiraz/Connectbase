# D:\Scripts\WebApp\app_AddressBilling\db\create_sql_objects.py
"""
Ensures that [ADDRESS_BILLING].UI_LZ, [Fuzzymatch_Output], plus
the Archive tables, and some indexes, *and also the Master + pivot tables*,
all exist in whichever STG/PRD DB we connect to (determined by hostname).

Usage:
  python create_sql_objects.py
"""

import sys, os
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))    # => D:\Scripts\WebApp\app_AddressBilling\db
WEBAPP_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, '..', '..'))
if WEBAPP_DIR not in sys.path:
    sys.path.insert(0, WEBAPP_DIR)

import logging
from sqlalchemy import create_engine, text
# Now it will find app_AddressBilling (the next line won't fail)
from app_AddressBilling.orchestration.ETL.odbc import _get_server_and_db

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    server, database = _get_server_and_db()
    driver = "ODBC Driver 17 for SQL Server"
    conn_str = f"mssql+pyodbc://@{server}/{database}?driver={driver}&Trusted_Connection=yes"
    engine = create_engine(conn_str, echo=False)

    logger.info(f"Ensuring AddressBilling objects exist on {server}/{database}...")

    statements = [
        # 1) UI_LZ
        """
        IF NOT EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = 'UI_LZ'
              AND SCHEMA_NAME(schema_id) = 'ADDRESS_BILLING'
        )
        BEGIN
            CREATE TABLE [ADDRESS_BILLING].[UI_LZ](
                [ID] [int] IDENTITY(1,1) NOT NULL,
                [user_def_row_ID] [nvarchar](100) NULL,
                [Address1] [nvarchar](255) NOT NULL,
                [Address2] [nvarchar](255) NULL,
                [City] [nvarchar](255) NOT NULL,
                [Zip] [nvarchar](255) NOT NULL,
                [State] [nvarchar](255) NOT NULL,
                [Country] [nvarchar](255) NULL,
                [DtmStamp] [datetime] NULL,
                [ingestion_timestamp] [datetime] NULL,
                [user_name] [nvarchar](255) NULL,
                [user_corp] [nvarchar](50) NULL,
                [batch_id] [uniqueidentifier] NOT NULL,
                [user_email] [nvarchar](255) NULL,
                [process_status] [nvarchar](50) NULL,
                CONSTRAINT [PK_ADDRESS_BILLING_UI_LZ] PRIMARY KEY CLUSTERED ([ID] ASC)
                WITH (
                  PAD_INDEX=OFF, STATISTICS_NORECOMPUTE=OFF,
                  IGNORE_DUP_KEY=OFF, ALLOW_ROW_LOCKS=ON, ALLOW_PAGE_LOCKS=ON
                ) ON [PRIMARY]
            ) ON [PRIMARY];

            ALTER TABLE [ADDRESS_BILLING].[UI_LZ]
            ADD CONSTRAINT [DF_UI_LZ_ingestion_timestamp]
                DEFAULT (getdate()) FOR [ingestion_timestamp];

            ALTER TABLE [ADDRESS_BILLING].[UI_LZ]
            ADD DEFAULT (newid()) FOR [batch_id];

            ALTER TABLE [ADDRESS_BILLING].[UI_LZ]
            ADD CONSTRAINT [DF_UI_LZ_process_status]
                DEFAULT ('pending') FOR [process_status];

            PRINT 'UI_LZ created.';
        END
        ELSE
        BEGIN
            PRINT 'UI_LZ already exists.';
        END
        """,

        # 2) Fuzzymatch_Output
        """
        IF NOT EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = 'Fuzzymatch_Output'
              AND SCHEMA_NAME(schema_id) = 'ADDRESS_BILLING'
        )
        BEGIN
            CREATE TABLE [ADDRESS_BILLING].[Fuzzymatch_Output](
                [batch_id] [varchar](36) NULL,
                [ID] [bigint] NULL,
                [ingestion_timestamp] [datetime] NULL,
                [user_def_row_ID] [varchar](100) NULL,
                [Input_Address] [varchar](200) NULL,
                [Matched_Address] [varchar](200) NULL,
                [Input_City] [varchar](100) NULL,
                [Matched_City] [varchar](100) NULL,
                [Input_State] [varchar](50) NULL,
                [Matched_State] [varchar](50) NULL,
                [Input_Zip] [varchar](20) NULL,
                [Matched_Zip] [varchar](20) NULL,
                [BLL_UniqueID] [varchar](50) NULL,
                [PRICING_TIER] [varchar](50) NULL,
                [LIT] [varchar](50) NULL,
                [EthernetLit] [varchar](50) NULL,
                [SWC] [varchar](50) NULL,
                [WIRELINE_ETH] [float] NULL,
                [WIRELESS_ETH] [float] NULL,
                [WHSL_DIA] [float] NULL,
                [BUS_DIA] [float] NULL,
                [BB] [float] NULL,
                [WAVELENGTH] [float] NULL,
                [TDM] [float] NULL,
                [SONET] [float] NULL,
                [VOICE] [float] NULL,
                [COLLO] [float] NULL
            ) ON [PRIMARY];
            PRINT 'Fuzzymatch_Output created.';
        END
        ELSE
        BEGIN
            PRINT 'Fuzzymatch_Output already exists.';
        END
        """,

        # 3) UI_LZ_Archive
        """
        IF NOT EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = 'UI_LZ_Archive'
              AND SCHEMA_NAME(schema_id) = 'ADDRESS_BILLING'
        )
        BEGIN
            CREATE TABLE [ADDRESS_BILLING].[UI_LZ_Archive](
                [ID] [int] IDENTITY(1,1) NOT NULL,
                [user_def_row_ID] [nvarchar](100) NULL,
                [Address1] [nvarchar](255) NOT NULL,
                [Address2] [nvarchar](255) NULL,
                [City] [nvarchar](255) NOT NULL,
                [Zip] [nvarchar](255) NOT NULL,
                [State] [nvarchar](255) NOT NULL,
                [Country] [nvarchar](255) NULL,
                [DtmStamp] [datetime] NULL,
                [ingestion_timestamp] [datetime] NULL,
                [user_name] [nvarchar](255) NULL,
                [user_corp] [nvarchar](50) NULL,
                [batch_id] [uniqueidentifier] NOT NULL,
                [user_email] [nvarchar](255) NULL,
                [process_status] [nvarchar](50) NULL,
                CONSTRAINT [PK_ADDRESS_BILLING_UI_LZ_Archive] PRIMARY KEY CLUSTERED ([ID] ASC)
                WITH (
                  PAD_INDEX=OFF, STATISTICS_NORECOMPUTE=OFF,
                  IGNORE_DUP_KEY=OFF, ALLOW_ROW_LOCKS=ON, ALLOW_PAGE_LOCKS=ON
                ) ON [PRIMARY]
            ) ON [PRIMARY];

            ALTER TABLE [ADDRESS_BILLING].[UI_LZ_Archive]
            ADD CONSTRAINT [DF_UI_LZ_Archive_ingestion_timestamp]
                DEFAULT (getdate()) FOR [ingestion_timestamp];

            ALTER TABLE [ADDRESS_BILLING].[UI_LZ_Archive]
            ADD DEFAULT (newid()) FOR [batch_id];

            ALTER TABLE [ADDRESS_BILLING].[UI_LZ_Archive]
            ADD CONSTRAINT [DF_UI_LZ_Archive_process_status]
                DEFAULT ('done') FOR [process_status];

            PRINT 'UI_LZ_Archive created.';
        END
        ELSE
        BEGIN
            PRINT 'UI_LZ_Archive already exists.';
        END
        """,

        # 4) Fuzzymatch_Output_Archive
        """
        IF NOT EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = 'Fuzzymatch_Output_Archive'
              AND SCHEMA_NAME(schema_id) = 'ADDRESS_BILLING'
        )
        BEGIN
            CREATE TABLE [ADDRESS_BILLING].[Fuzzymatch_Output_Archive](
                [batch_id] [varchar](36) NULL,
                [ID] [bigint] NULL,
                [ingestion_timestamp] [datetime] NULL,
                [user_def_row_ID] [varchar](100) NULL,
                [Input_Address] [varchar](200) NULL,
                [Matched_Address] [varchar](200) NULL,
                [Input_City] [varchar](100) NULL,
                [Matched_City] [varchar](100) NULL,
                [Input_State] [varchar](50) NULL,
                [Matched_State] [varchar](50) NULL,
                [Input_Zip] [varchar](20) NULL,
                [Matched_Zip] [varchar](20) NULL,
                [BLL_UniqueID] [varchar](50) NULL,
                [PRICING_TIER] [varchar](50) NULL,
                [LIT] [varchar](50) NULL,
                [EthernetLit] [varchar](50) NULL,
                [SWC] [varchar](50) NULL,
                [WIRELINE_ETH] [float] NULL,
                [WIRELESS_ETH] [float] NULL,
                [WHSL_DIA] [float] NULL,
                [BUS_DIA] [float] NULL,
                [BB] [float] NULL,
                [WAVELENGTH] [float] NULL,
                [TDM] [float] NULL,
                [SONET] [float] NULL,
                [VOICE] [float] NULL,
                [COLLO] [float] NULL
            ) ON [PRIMARY];
            PRINT 'Fuzzymatch_Output_Archive created.';
        END
        ELSE
        BEGIN
            PRINT 'Fuzzymatch_Output_Archive already exists.';
        END
        """,

        # 5) ADDR_BILLING_MASTER (table used by Master_Match_File.py)
        """
        IF NOT EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = 'ADDR_BILLING_MASTER'
              AND SCHEMA_NAME(schema_id) = 'ADDRESS_BILLING'
        )
        BEGIN
            CREATE TABLE [ADDRESS_BILLING].[ADDR_BILLING_MASTER](
                [UniqueID]       [varchar](50) NULL,
                [ADDRESS]        [varchar](200) NULL,
                [CITY]           [varchar](100) NULL,
                [STATE]          [varchar](50)  NULL,
                [ZIP]            [varchar](20)  NULL,
                [PRICING_TIER]   [varchar](50)  NULL,
                [LIT]            [varchar](50)  NULL,
                [EthernetLit]    [varchar](50)  NULL,
                [SWC]            [varchar](50)  NULL,
                [WIRELINE_ETH]   [float]        NULL,
                [WIRELESS_ETH]   [float]        NULL,
                [WHSL_DIA]       [float]        NULL,
                [BUS_DIA]        [float]        NULL,
                [BB]             [float]        NULL,
                [WAVELENGTH]     [float]        NULL,
                [TDM]            [float]        NULL,
                [SONET]          [float]        NULL,
                [VOICE]          [float]        NULL,
                [COLLO]          [float]        NULL
            ) ON [PRIMARY];
            PRINT 'ADDR_BILLING_MASTER created.';
        END
        ELSE
        BEGIN
            PRINT 'ADDR_BILLING_MASTER already exists.';
        END
        """,

        # 6) CABS_ADDR_PRD_PIVOT (table read by Master_Match_File.py)
        """
        IF NOT EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = 'CABS_ADDR_PRD_PIVOT'
              AND SCHEMA_NAME(schema_id) = 'ADDRESS_BILLING'
        )
        BEGIN
            CREATE TABLE [ADDRESS_BILLING].[CABS_ADDR_PRD_PIVOT](
                [ADDRESS]       [varchar](200) NULL,
                [CITY]          [varchar](100) NULL,
                [STATE]         [varchar](50)  NULL,
                [ZIP]           [varchar](20)  NULL,
                [COLLO]         [float]        NULL,
                [SONET]         [float]        NULL,
                [TDM]           [float]        NULL,
                [WAVELENGTH]    [float]        NULL,
                [WIRELESS_ETH]  [float]        NULL,
                [WIRELINE_ETH]  [float]        NULL
            ) ON [PRIMARY];
            PRINT 'CABS_ADDR_PRD_PIVOT created.';
        END
        ELSE
        BEGIN
            PRINT 'CABS_ADDR_PRD_PIVOT already exists.';
        END
        """,

        # 7) CARS_ADDR_PRD_PIVOT (table read by Master_Match_File.py)
        """
        IF NOT EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = 'CARS_ADDR_PRD_PIVOT'
              AND SCHEMA_NAME(schema_id) = 'ADDRESS_BILLING'
        )
        BEGIN
            CREATE TABLE [ADDRESS_BILLING].[CARS_ADDR_PRD_PIVOT](
                [ADDRESS] [varchar](200) NULL,
                [CITY]    [varchar](100) NULL,
                [STATE]   [varchar](50)  NULL,
                [ZIP]     [varchar](20)  NULL,
                [BB]      [float]        NULL,
                [BUS_DIA] [float]        NULL,
                [VOICE]   [float]        NULL,
                [WHSL_DIA][float]        NULL
            ) ON [PRIMARY];
            PRINT 'CARS_ADDR_PRD_PIVOT created.';
        END
        ELSE
        BEGIN
            PRINT 'CARS_ADDR_PRD_PIVOT already exists.';
        END
        """,

        # 8) 24Q4_BLDG_LIST (table read by Master_Match_File.py)
        """
        IF NOT EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = '24Q4_BLDG_LIST'
              AND SCHEMA_NAME(schema_id) = 'ADDRESS_BILLING'
        )
        BEGIN
            CREATE TABLE [ADDRESS_BILLING].[24Q4_BLDG_LIST](
                [UniqueID]                [varchar](50) NULL,
                [ADDR]                    [varchar](200) NULL,
                [CITY]                    [varchar](100) NULL,
                [STATE]                   [varchar](50)  NULL,
                [ZIP]                     [varchar](20)  NULL,
                [PRICING_TIER]           [varchar](50)  NULL,
                [LIT]                     [varchar](50)  NULL,
                [EthernetLit]            [varchar](50)  NULL,
                [SWC]                     [varchar](50)  NULL,
                [ENV]                     [varchar](50)  NULL,
                [CONTROL]                 [varchar](50)  NULL,
                [LAT]                     [varchar](50)  NULL,
                [LON]                     [varchar](50)  NULL,
                [MTU]                     [varchar](50)  NULL,
                [22_TIER]                 [varchar](50)  NULL,
                [23_TIER]                 [varchar](50)  NULL,
                [23Q3_TIER]               [varchar](50)  NULL,
                [23Q3_CIAC]               [varchar](50)  NULL,
                [23Q3_COLOR]              [varchar](50)  NULL,
                [23Q3_DISTANCE]           [varchar](50)  NULL,
                [AM_GUID]                 [varchar](50)  NULL,
                [Connected2FiberUniqueKey][varchar](50)  NULL,
                [SOURCE]                  [varchar](50)  NULL,
                [DSAT_TIER]               [varchar](50)  NULL,
                [FIBER_DIST]              [varchar](50)  NULL,
                [FIBER_DIST_IND]          [varchar](50)  NULL,
                [MAX_BDW]                 [varchar](50)  NULL,
                [SILVER]                  [varchar](50)  NULL,
                [GOLD_PLATINUM]           [varchar](50)  NULL,
                [EPATH]                   [varchar](50)  NULL,
                [EIA]                     [varchar](50)  NULL,
                [FIBER_CIAC_ESTIMATE]     [varchar](50)  NULL
            ) ON [PRIMARY];
            PRINT '24Q4_BLDG_LIST created.';
        END
        ELSE
        BEGIN
            PRINT '24Q4_BLDG_LIST already exists.';
        END
        """,

        # 9) Example index on Fuzzymatch_Output (already shown, just in case):
        """
        IF NOT EXISTS (
            SELECT 1
            FROM sys.indexes
            WHERE object_id = OBJECT_ID(N'[ADDRESS_BILLING].[Fuzzymatch_Output]')
              AND name = 'IX_Fuzzymatch_Output_batchid_id'
        )
        BEGIN
            CREATE NONCLUSTERED INDEX [IX_Fuzzymatch_Output_batchid_id]
                ON [ADDRESS_BILLING].[Fuzzymatch_Output] ([batch_id],[ID])
                WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, ONLINE = ON);
            PRINT 'Created index IX_Fuzzymatch_Output_batchid_id.';
        END
        ELSE
        BEGIN
            PRINT 'Index IX_Fuzzymatch_Output_batchid_id already exists.';
        END
        """
    ]

    with engine.begin() as conn:
        for stmt in statements:
            try:
                conn.execute(text(stmt))
            except Exception as ex:
                logger.warning(f"Ignored error while running:\n{stmt}\nError: {ex}")

    logger.info("SQL object creation/check completed successfully.")

if __name__ == "__main__":
    main()
