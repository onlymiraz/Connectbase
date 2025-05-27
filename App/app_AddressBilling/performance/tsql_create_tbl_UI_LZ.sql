USE [Playground]
GO

/****** Object:  Table [addressbilling].[UI_LZ]    Script Date: 2/11/2025 10:05:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [addressbilling].[UI_LZ](
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
 CONSTRAINT [PK_addressbilling.UI_LZ] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [addressbilling].[UI_LZ] ADD  CONSTRAINT [DF__UI_LZ__ingestion__7093AB15]  DEFAULT (getdate()) FOR [ingestion_timestamp]
GO

ALTER TABLE [addressbilling].[UI_LZ] ADD  DEFAULT (newid()) FOR [batch_id]
GO

ALTER TABLE [addressbilling].[UI_LZ] ADD  CONSTRAINT [DF_UI_LZ_process_status]  DEFAULT ('pending') FOR [process_status]
GO


