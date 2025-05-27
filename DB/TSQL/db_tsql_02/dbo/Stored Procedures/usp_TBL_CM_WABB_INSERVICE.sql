CREATE PROCEDURE dbo.usp_TBL_CM_WABB_INSERVICE
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
        'dbo.usp_TBL_CM_WABB_INSERVICE',
        CAST(GETDATE() AS DATETIME),
        'STORE PROC',
        'INSERTING CM WABB INSERVICE DATA'
    );

    SET @EVENTID = SCOPE_IDENTITY();

    BEGIN TRANSACTION

    -- delete current and prior month before insert
    DELETE FROM dbo.TBL_CM_WABB_INSERVICE 
    WHERE BILL_MONTH >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0);

    -- Insert data from LZ.TBL_CM_WABB_INSERVICE into dbo.TBL_CM_WABB_INSERVICE
    INSERT INTO dbo.TBL_CM_WABB_INSERVICE
    (
        [BILL_MONTH],
        [CARRIER],
        [CCNA],
        [ADDRESS],
        [CITY],
        [STATE],
        [ZIP],
        [SERVICE_TYPE],
        [TARIFF_CD],
        [PRODUCT],
        [WTN],
        [BTN],
        [STN],
        [GL_MATRIX_CLASS],
        [PRD_SVC_CD],
        [PRD_SVC_CD_DS],
        [TOTAL_MRC],
        [CUSTNAME]
    )
    SELECT 
        [BILL_MONTH],
        [CARRIER],
        [CCNA],
        [ADDRESS],
        [CITY],
        [STATE],
        [ZIP],
        [SERVICE_TYPE],
        [TARIFF_CD],
        [PRODUCT],
        [WTN],
        [BTN],
        [STN],
        [GL_MATRIX_CLASS],
        [PRD_SVC_CD],
        [PRD_SVC_CD_DS],
        [TOTAL_MRC],
        [CUSTNAME]
    FROM LZ.TBL_CM_WABB_INSERVICE;

    COMMIT TRANSACTION;

    UPDATE L
    SET L.EVENTEND = CAST(GETDATE() AS DATETIME)
    FROM [LOG].tbl_StoreProc L
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
