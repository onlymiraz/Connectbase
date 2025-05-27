USE [Playground]
GO

/****** Object:  Table [addressbilling].[Fuzzymatch_Output]    Script Date: 2/11/2025 10:05:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [addressbilling].[Fuzzymatch_Output](
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
) ON [PRIMARY]
GO


