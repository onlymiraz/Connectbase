CREATE PROCEDURE QBR.[usp_TBL_COMPLETED_ORDERS]

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
        'EDW_VWMC.[usp_TBL_COMPLETED_ORDERS]',
        CAST(GETDATE() AS DATETIME),
        'STORE PROC',
        'SINGLE_INGESTION'
    )

    SET @EVENTID = SCOPE_IDENTITY();

	BEGIN TRANSACTION

    DELETE FROM QBR.TBL_COMPLETED_ORDERS WHERE DD_COMP >=DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0);

    INSERT INTO QBR.TBL_COMPLETED_ORDERS
    SELECT [DOCNO]
          ,[REQ]
          ,[ACT]
          ,[BUILD]
          ,[BUILD_IOF]
          ,[BUILD_OSP]
          ,[UNI_OR_NNI]
          ,[INIT]
          ,[CLEAN]
          ,[DD]
          ,[COMP_DT]
          ,[DD_COMP]
          ,[NC]
          ,[PROD]
          ,[PNUM]
          ,[PON]
          ,[CKT]
          ,[ICSC]
          ,[ACNA]
          ,[COMP]
          ,[WHY_MISS1]
          ,[MISS_REASON1]
          ,[PROJ]
          ,[STATE]
          ,[REGION]
          ,[PRODUCT]
          ,[PRODUCT2]
          ,[SEI]
          ,[BDW]
          ,[DD_MET]
          ,[DLR]
          ,CASE WHEN ISDATE([CRDD]) = 1 THEN CAST([CRDD] AS DATETIME) ELSE NULL END AS CRDD
          ,[CRDD_STATUS]

      FROM [LZ].[TBL_COMPLETED_ORDERS]
	
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