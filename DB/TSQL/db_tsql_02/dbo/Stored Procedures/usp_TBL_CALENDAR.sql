create PROCEDURE dbo.[usp_TBL_CALENDAR]
	-- Add any parameters for the stored procedure here

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
		'dbo.[usp_TBL_CALENDAR]',
		CAST(GETDATE() AS DATETIME),
		'STORE PROC',
		'updates the column in the table'
	)

	SET @EVENTID = SCOPE_IDENTITY();

	BEGIN TRANSACTION

UPDATE dbo.calendar
SET THURSDAY_WEEKEND_DATE = 
    CASE 
        -- If the date is already Thursday
        WHEN DATEPART(dw, calendar_date) = 5 THEN calendar_date
        -- Otherwise, calculate the next Thursday
        ELSE DATEADD(DAY, (5 - DATEPART(dw, calendar_date) + 7) % 7, calendar_date)
    END;

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
