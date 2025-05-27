create PROCEDURE dbo.[usp_BoilerPlate]
	-- Add any parameters for the stored procedure here
	@var1 int,
	@var2 int
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS #t
INSERT INTO [LOG].tbl_storeproc
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])

--enter values below

VALUES
('dbo.[usp_test]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'hourly program run for test')



SELECT MAX(EVENTID) AS LATESTID  INTO #t
FROM [LOG].tbl_storeproc

/*

write code here

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