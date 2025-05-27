create PROCEDURE dbo.[usp_BoilerPlate]
	-- Add any parameters for the stored procedure here
	@var1 int,
	@var2 int
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY

	DECLARE @EVENTID INT;

	INSERT INTO [LOG].tbl_StoreProc
    (
		[EVENTNAME],
		[EVENTSTART],
		[EVENTTYPE],
		[EVENTDESCRIPTION]
	)
	VALUES
	(
		'dbo.[usp_test]',
		CAST(GETDATE() AS DATETIME),
		'STORE PROC',
		'hourly program run for test'
	)

	SET @EVENTID = SCOPE_IDENTITY();

	BEGIN TRANSACTION

	/*

	write code here

	*/

	COMMIT TRANSACTION

	UPDATE L
    SET L.EVENTEND = CAST(GETDATE() AS DATETIME)
    FROM LOG.tbl_StoreProc L
    WHERE L.EVENTID = @EventID;

END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH