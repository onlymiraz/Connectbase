CREATE PROCEDURE [Forecast].[Parser_PJAPIP003]
AS
/****** Object:  StoredProcedure [PushPull].[Parser_PushPull]    Script Date: 5/4/2023 1:36:37 PM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Parser_PJAPIP003
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[Forecast].[parser_PJAPIP003]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Ingest PJAPIP00X.csv')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Parser_PJAPIP003
	FROM [LOG].[Tracker]
	
	SET NOCOUNT ON;

	truncate table [LZ].[LZ_PJAPIP003]

	bulk insert [LZ].[LZ_PJAPIP003] from 'd:\DataDump\PJAPIP00X.csv'
    with (fieldterminator=',', rowterminator='\n', codepage=65001, FIRSTROW=2)

	update [LZ].[LZ_PJAPIP003]
	set		Company = REPLACE(Company, '"', ''),
	ProjectNumber = REPLACE(ProjectNumber, '"', ''),
	Subproject = REPLACE(Subproject, '"', ''),
	Suffix = REPLACE(Suffix, '"', ''),
	Invdate = REPLACE(Invdate, '"', ''),
	DDESC = REPLACE(DDESC, '"', ''),	
	Serno = REPLACE(Serno, '"', ''),
	SrcCode = REPLACE(SrcCode, '"', ''),
	STDDIV = REPLACE(STDDIV, '"', ''),
	STDCO1 = REPLACE(STDCO1, '"', ''),
	CostCode = REPLACE(CostCode, '"', ''),
	TRNdate = REPLACE(TRNdate, '"', ''),
	TRNdate2 = REPLACE(TRNdate2, '"', ''),
	QuantD = REPLACE(QuantD, '"', ''),
	UnitCS = REPLACE(UnitCS, '"', ''),
	AstDte = REPLACE(AstDte, '"', ''),
	AstDte2 = REPLACE(AstDte2, '"', ''),
	PONumber = REPLACE(PONumber, '"', ''),
	POLine = REPLACE(POLine, '"', ''),
	VXComd = REPLACE(VXComd, '"', ''),
	USRF13 = REPLACE(USRF13, '"', ''),
	VINVAD = REPLACE(VINVAD, '"', ''),
	DETAMT = REPLACE(DETAMT, '"', ''),
	AccountNumber = REPLACE(AccountNumber, '"', ''),
	INVALP = REPLACE(INVALP, '"', ''),
	VoucherNumber = REPLACE(VoucherNumber, '"', ''),
	Chase2 = REPLACE(Chase2, '"', ''),
	VendorNumber = REPLACE(VendorNumber, '"', ''),
	USRFL3 = REPLACE(USRFL3, '"', ''),
	VHOURD = REPLACE(VHOURD, '"', ''),
	LINBUD = REPLACE(LINBUD, '"', ''),
	VPartNumber = REPLACE(VPartNumber, '"', '')

	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Parser_PJAPIP003 P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_Parser_PJAPIP003

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH