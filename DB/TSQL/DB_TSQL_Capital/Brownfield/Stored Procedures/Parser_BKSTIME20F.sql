CREATE procedure [Brownfield].[Parser_BKSTIME20F]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Parser_BKSTIME20F
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[Brownfield].[Parser_LZ_BKSTIME20F]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Ingest BKSTIME20F.csv')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Parser_LZ_BKSTIME20F
	FROM [LOG].[Tracker]
	
	SET NOCOUNT ON;

	truncate table [Brownfield].[LZ_BKSTIME20F]

	bulk insert [Brownfield].[LZ_BKSTIME20F] from '\\CAPINFWWWPV01\DataDump\BKSTIME20F.csv'
	with (fieldterminator='|', rowterminator='0x0a', codepage=65001, FIRSTROW=2)

	update [Brownfield].[LZ_BKSTIME20F]
	set ReportBreakLevel = REPLACE(ReportBreakLevel, '"', ''),
	CalculationOverflow = REPLACE(CalculationOverflow, '"', ''),
	CHGCMP = REPLACE([CHGCMP], '"', ''),
	CMPNBR = REPLACE(CMPNBR, '"', ''),
	PRJNBR = REPLACE(PRJNBR, '"', ''),
	SUBPRJ = REPLACE(SUBPRJ, '"', ''),
	ACCTYR = REPLACE(ACCTYR, '"', ''),
	ACCTMN = REPLACE(ACCTMN, '"', '')
	

	--update [Brownfield].[LZ_BKSTIME20F]
	--set VendorNumber = REPLACE(VendorNumber, ' ', '')

	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Parser_LZ_BKSTIME20F P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_Parser_LZ_BKSTIME20F

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH