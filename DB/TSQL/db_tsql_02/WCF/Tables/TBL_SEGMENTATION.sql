CREATE TABLE WCF.[TBL_SEGMENTATION]
(
	[Wirecenter] [nvarchar](255) NULL,
	[ABU > 81% of Customers] [float] NULL,
	[ABU 61-80% of Customers] [float] NULL,
	[ABU 41-60% of Customers] [float] NULL,
	[ABU 21-40% of Customers] [float] NULL,
	[ABU 1-20% of Customers] [float] NULL,
	[ABU 0% of Customers] [float] NULL,
	[BEAD > 81% of Customers] [float] NULL,
	[BEAD 61-80% of Customers] [float] NULL,
	[BEAD 41-60% of Customers] [float] NULL,
	[BEAD 21-40% of Customers] [float] NULL,
	[BEAD 1-20% of Customers] [float] NULL,
	[BEAD 0% of Customers] [float] NULL,
	[Hyperion] [float] NULL,
	[Regulatory Guidance - Green] [float] NULL,
	[Regulatory Guidance - Yellow] [float] NULL,
	[Regulatory Guidance - Red] [float] NULL,
	[Tarriff Restrictions - Green] [float] NULL,
	[Tarriff Restrictions - Yellow] [float] NULL,
	[Tarriff Restrictions - Red] [float] NULL,
	RPT_MTH DATE
)
