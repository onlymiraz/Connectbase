CREATE procedure [Brownfield].[Parser_BKSTIME00F]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Parser_BKSTIME00F
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[Brownfield].[Parser_LZ_BKSTIME00F]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Ingest BKSTIME00F.csv')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Parser_LZ_BKSTIME00F
	FROM [LOG].[Tracker]
	
	SET NOCOUNT ON;

	truncate table [Brownfield].[LZ_BKSTIME00F]

	bulk insert [Brownfield].[LZ_BKSTIME00F] from '\\CAPINFWWWPV01\DataDump\BKSTIME00F.csv'
	with (fieldterminator='|', rowterminator='0x0a', codepage=65001, FIRSTROW=2)

	update [Brownfield].[LZ_BKSTIME00F]
	set 	WorkDate = REPLACE(WorkDate, '"', ''),
	CO# = REPLACE(CO#, '"', ''),
	PROJECT = REPLACE(PROJECT, '"', ''),
	SUBPROJ = REPLACE(SUBPROJ, '"', ''),
	[Hours] = REPLACE([Hours], '"', ''),
	CostCode = REPLACE(CostCode, '"', '')	

	--update [Brownfield].[LZ_BKSTIME00F]
	--set VendorNumber = REPLACE(VendorNumber, ' ', '')

	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Parser_LZ_BKSTIME00F P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_Parser_LZ_BKSTIME00F

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH