CREATE PROCEDURE [Brownfield].[Parser_JMJC5FLDSF]
AS
/****** Object:  StoredProcedure [Brownfield].[Parser_JMJC5FLDSF]    Script Date: 5/4/2023 1:36:37 PM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Parser_LZ_JMJC5FLDSF
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[Brownfield].[Parser_LZ_JMJC5FLDSF]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Ingest JMJC5FLDSF.csv')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Parser_LZ_JMJC5FLDSF
	FROM [LOG].[Tracker]
	
	SET NOCOUNT ON;

	truncate table [Brownfield].[LZ_JMJC5FLDSF]

	bulk insert [Brownfield].[LZ_JMJC5FLDSF] from '\\CAPINFWWWPV01.corp.pvt\DataDump\JMJC5FLDSF.csv'
	with (fieldterminator='|', rowterminator='0x0a', codepage=65001, FIRSTROW=2)

	update [Brownfield].[LZ_JMJC5FLDSF]
	set 	Proj# = REPLACE(Proj#, '"', ''),
	Sub# = REPLACE(Sub#, '"', ''),
	JC = REPLACE(JC, '"', ''),
	COP = REPLACE(COP, '"', ''),
	LinkCd = REPLACE(LinkCd, '"', ''),
	FG = REPLACE(FG, '"', ''),
	ProjectDescription = REPLACE(ProjectDescription, '"', ''),
	Sts = REPLACE(Sts, '"', ''),
	AP = REPLACE(AP, '"', ''),
	Co# = REPLACE(Co#, '"', ''),
	Exch# = REPLACE(Exch#, '"', ''),
	OA = REPLACE(OA, '"', ''),
	St = REPLACE(St, '"', ''),
	Engineer = REPLACE(Engineer, '"', ''),
	OrigBdgt$ = REPLACE(OrigBdgt$, '"', ''),
	RevBdgt$1 = REPLACE(RevBdgt$1, '"', ''),
	RevBdgt$2 = REPLACE(RevBdgt$2, '"', ''),
	Spent$ = REPLACE(Spent$, '"', ''),
	APDate = REPLACE(APDate, '"', ''),
	EstStrtDte = REPLACE(EstStrtDte, '"', ''),
	EstCompDte = REPLACE(EstCompDte, '"', ''),
 	ActStartDte = REPLACE(ActStartDte, '"', ''),
	RFSDate = REPLACE(RFSDate, '"', ''),
	TntvCLDte = REPLACE(TntvCLDte, '"', ''),
	ProjCLDate = REPLACE(ProjCLDate, '"', '')

	--update [Brownfield].[LZ_JMJC5FLDSF]
	--set VendorNumber = REPLACE(VendorNumber, ' ', '')

	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Parser_LZ_JMJC5FLDSF P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_Parser_LZ_JMJC5FLDSF

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH