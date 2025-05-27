
CREATE PROCEDURE TOWERS_UNIVERSE.usp_parser_TBL_DATA_DICT
/*
	-- Add any parameters for the stored procedure here
	@var1 int,
	@var2 int
*/
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS #t
INSERT INTO [LOG].tbl_StoreProc
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])

--enter values below

VALUES
('TOWERS_UNIVERSE.TBL_DATA_DICT'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'SINGLE_INGESTION')



SELECT MAX(EVENTID) AS LATESTID  INTO #t
FROM [LOG].tbl_StoreProc


	truncate table TOWERS_UNIVERSE.TBL_DATA_DICT --Cannot truncate system versioned table

	bulk insert TOWERS_UNIVERSE.TBL_DATA_DICT from '\\Wadinfwwddv01\lz\TOWERS_UNIVERSE\towers_data_dictionary.csv'
    with (FIELDTERMINATOR = ',',FIRSTROW=2)

/*

	/*
	
	truncate table TOWERS_UNIVERSE.tbl_BoilerPlate

	bulk insert TOWERS_UNIVERSE.tbl_BoilerPlate from 'd:\DataDump\somecsv.csv'
    with (fieldterminator='|', rowterminator='\n', codepage=65001, FIRSTROW=2)

	update [Safety].[TOWERS_UNIVERSE_MZEESAFETY]
	set		CRIS = REPLACE(CRIS, '"', ''),
	EMPLOYEENAME = REPLACE(EMPLOYEENAME, '"', ''),
	FIRSTNAME = REPLACE(FIRSTNAME, '"', ''),
	LASTNAME = REPLACE(LASTNAME, '"', ''),
	MI = REPLACE(MI, '"', ''),
	TITLE = REPLACE(TITLE, '"', ''),	
	STAT = REPLACE(STAT, '"', ''),
	LOCCODE = REPLACE(LOCCODE, '"', ''),
	WORKSTATE = REPLACE(WORKSTATE, '"', ''),
	BAND = REPLACE(BAND, '"', ''),
	LABORCAT = REPLACE(LABORCAT, '"', ''),
	[UNION] = REPLACE([UNION], '"', ''),
	[FUNCTION] = REPLACE([FUNCTION], '"', ''),
	SUPERVISORNAME = REPLACE(SUPERVISORNAME, '"', ''),
	SUPERVISORPOS = REPLACE(SUPERVISORPOS, '"', ''),
	EMAIL = REPLACE(EMAIL, '"', ''),
	SUPERVISORCRIS# = REPLACE(SUPERVISORCRIS# , '"', ''),
	RLSP13CRIS# = REPLACE(RLSP13CRIS#, '"', ''),
	RLSP13NAME = REPLACE(RLSP13NAME, '"', ''),
	CORPID = REPLACE(CORPID, '"', '')

	*/

*/
	
	
UPDATE L
SET L.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.tbl_StoreProc L
INNER JOIN #t
ON L.EVENTID = #t.LATESTID
DROP TABLE IF EXISTS #t


	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH