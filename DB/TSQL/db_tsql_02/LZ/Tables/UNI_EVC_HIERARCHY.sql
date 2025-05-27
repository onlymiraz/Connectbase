CREATE TABLE [LZ].[UNI_EVC_HIERARCHY](
	[STATE] [varchar](2) NULL,
	[SERVICE_TYPE_CODE] [varchar](10) NULL,
	[EVC_DSGN_ID] [int] NULL,
	[LAST_MODIFIED_DATE] [datetime] NULL,
	[STATUS_DESC] [varchar](22) NULL,
	[CLEAN_EVC_ID] [varchar](4000) NULL,
	[EVC_CIRCUIT] [varchar](53) NULL,
	[EVC_SPEED] [float] NULL,
	[EVC_RELATED_TO_N] [float] NULL,
	[CLEAN_UNI_ID] [varchar](4000) NULL,
	[UNI_CIRCUIT] [varchar](53) NULL,
	[UNI_NNI] [varchar](3) NULL,
	[UNI_RELATED_TO_N] [float] NULL,
	[RANK] [float] NULL,
	[DLR_ACNA] [varchar](3) NULL,
	[PRIMARY_CARRIER_NAME] [varchar](200) NULL
);