CREATE PROCEDURE dbo.usp_TBL_CONTRACT_INFORMATION_INSERVICE
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
        'dbo.usp_TBL_CONTRACT_INFORMATION_INSERVICE',
        CAST(GETDATE() AS DATETIME),
        'STORE PROC',
        'INSERTING CONTRACT INFORMATION DATA'
    );

    SET @EVENTID = SCOPE_IDENTITY();

    BEGIN TRANSACTION

    -- Delete current and prior month before insert
    DELETE FROM dbo.TBL_CONTRACT_INFORMATION 
    WHERE OFFER_DATE >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0);

    -- Insert data from LZ.TBL_CONTRACT_INFORMATION into dbo.TBL_CONTRACT_INFORMATION
    INSERT INTO dbo.TBL_CONTRACT_INFORMATION
    (
        [BANCARCD],
        [BTN],
        [STN],
        [WTN],
        [SUBLSN],
        [SUBFRN],
        [SUBCDT],
        [SUBDDT],
        [ADDRESS_LINE_1],
        [ADDRESS_LINE_2],
        [CITY],
        [STATE],
        [POSTAL_CODE],
        [CONTRACT_ID],
        [DESCRIPTION],
        [CONTRACT_TYPE],
        [OFFER_DATE],
        [EFFECTIVE_DATE],
        [EXPIRATION_DATE],
        [TERM],
        [STATUS]
    )
    SELECT 
        [BANCARCD],
        [BTN],
        [STN],
        [WTN],
        [SUBLSN],
        [SUBFRN],
        [SUBCDT],
        [SUBDDT],
        [ADDRESS_LINE_1],
        [ADDRESS_LINE_2],
        [CITY],
        [STATE],
        [POSTAL_CODE],
        [CONTRACT_ID],
        [DESCRIPTION],
        [CONTRACT_TYPE],
        [OFFER_DATE],
        [EFFECTIVE_DATE],
        [EXPIRATION_DATE],
        [TERM],
        [STATUS]
    FROM LZ.TBL_CONTRACT_INFORMATION;

    COMMIT TRANSACTION;

    UPDATE L
    SET L.EVENTEND = CAST(GETDATE() AS DATETIME)
    FROM LOG.tbl_StoreProc L
    WHERE L.EVENTID = @EventID;

END TRY
BEGIN CATCH
    -- Rollback the transaction if there's an error
    IF @@trancount > 0 ROLLBACK TRANSACTION;
    
    -- Call the error handler
    EXEC usp_error_handler;
    
    -- Return error code
    RETURN 55555;
END CATCH;
GO
