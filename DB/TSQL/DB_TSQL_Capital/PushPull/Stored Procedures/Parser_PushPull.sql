CREATE PROCEDURE [PushPull].[Parser_PushPull]
AS
/****** Object:  StoredProcedure [PushPull].[Parser_PushPull]    Script Date: 5/4/2023 1:36:37 PM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Parser_PushPull
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[PushPull].[Parser_PushPull]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Ingest PUSHPULL.csv')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Parser_PushPull
	FROM [LOG].[Tracker]
	
	SET NOCOUNT ON;

	truncate table [PushPull].[LZ_PushPull]

	bulk insert [PushPull].[LZ_PushPull] from 'd:\DataDump\pushpull.csv'
    with (fieldterminator='|', rowterminator='\n', codepage=65001, FIRSTROW=2)

	update [PushPull].[LZ_PushPull]
	set		CompanyNumber = REPLACE(CompanyNumber, '"', ''),
	Exch# = REPLACE(Exch#, '"', ''),
	ProjectMasterNumbr = REPLACE(ProjectMasterNumbr, '"', ''),
	LineSubProject# = REPLACE(LineSubProject#, '"', ''),
	ProjJustificatCode = REPLACE(ProjJustificatCode, '"', ''),
	CostCode = REPLACE(CostCode, '"', ''),	
	LineBudgetAmount = REPLACE(LineBudgetAmount, '"', ''),
	ProjectTypeCode = REPLACE(ProjectTypeCode, '"', ''),
	OrigBudgetAmount = REPLACE(OrigBudgetAmount, '"', '')

	--update [Brownfield].[LZ_JMAUTHDTLF]
	--set VendorNumber = REPLACE(VendorNumber, ' ', '')

	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Parser_PushPull P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_Parser_PushPull

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH