CREATE PROCEDURE [Brownfield].[Parser_JMAUTHDTLF]
AS
/****** Object:  StoredProcedure [Brownfield].[Parser_JMAUTHDTLF]    Script Date: 5/4/2023 1:36:37 PM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Parser_JMAUTHDTLF
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[Brownfield].[Parser_LZ_JMAUTHDTLF]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Ingest JMAUTHDTLF.csv')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Parser_LZ_JMAUTHDTLF
	FROM [LOG].[Tracker]
	
	SET NOCOUNT ON;

	truncate table [Brownfield].[LZ_JMAUTHDTLF]

	bulk insert [Brownfield].[LZ_JMAUTHDTLF] from '\\CAPINFWWWPV01.corp.pvt\DataDump\JMAUTHDTLF.csv'
	with (fieldterminator='|', rowterminator='0x0a', codepage=65001, FIRSTROW=2)

	update [Brownfield].[LZ_JMAUTHDTLF]
	set 	JC = REPLACE(JC, '"', ''),
	Proj# = REPLACE(Proj#, '"', ''),
	Sub# = REPLACE(Sub#, '"', ''),
	CC = REPLACE(CC, '"', ''),
	LINEDESCRIPTION = REPLACE(LINEDESCRIPTION, '"', ''),
	Budget$ = REPLACE(Budget$, '"', ''),
	ADDCHANGETERMINAL = REPLACE(ADDCHANGETERMINAL, '"', '')	

	--update [Brownfield].[LZ_JMAUTHDTLF]
	--set VendorNumber = REPLACE(VendorNumber, ' ', '')

	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Parser_LZ_JMAUTHDTLF P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_Parser_LZ_JMAUTHDTLF

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH