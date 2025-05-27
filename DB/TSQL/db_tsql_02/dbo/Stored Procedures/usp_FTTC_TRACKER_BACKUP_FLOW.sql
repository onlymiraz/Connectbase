CREATE PROCEDURE [dbo].[usp_FTTC_TRACKER_BACKUP_FLOW]
	
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
		'ingest FTTCTrackerBackupFlow.xlsx'
	)

	SET @EVENTID = SCOPE_IDENTITY();

	TRUNCATE TABLE [LZ].[FTTC_TRACKER_BACKUP_FLOW]

	BEGIN TRY

		BEGIN TRANSACTION LZInsert

			INSERT INTO [LZ].[FTTC_TRACKER_BACKUP_FLOW]
			SELECT * 
			FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
							'Excel 12.0 Xml;HDR=YES;Database=D:\LZ\Wireless_Data_Automation\FTTCTrackerBackupFlow.xlsx',
							'SELECT * FROM [Sheet1$]');

		COMMIT TRANSACTION LZInsert
	
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION LZInsert;

		THROW;

	END CATCH

	BEGIN TRY
        
        TRUNCATE TABLE [dbo].[FTTC_TRACKER_BACKUP_FLOW]

        BEGIN TRANSACTION FinalInsert

		    insert into [dbo].[FTTC_TRACKER_BACKUP_FLOW]
            select 
                [DATE TIME],
                [CUSTOMER],
                [PROJECT NAME],
                [BDT],
                [SITE ID],
                [Site Select],
                [LATA],
                [ADDRESS],
                [STATE],
                [SWC],
                [BW],
                [HBE],
                [TIER],
                [Build Time],
                [Interconnect Point],
                [SPOF],
                [SRG],
                [Latency Odd],
                [Latency Even],
                TRY_CAST([DIRECT LATA SUMMARY TOTAL] AS DECIMAL(18,2)),
                TRY_CAST([DIRECT OSP TOTAL] AS DECIMAL(18,2)),
                TRY_CAST([DIRECT BB TOTAL] AS DECIMAL(18,2)),
                TRY_CAST([DIRECT TR TOTAL] AS DECIMAL(18,2)),
                TRY_CAST([DIRECT INDIVIDAL CS COST] AS DECIMAL(18,2)),
                TRY_CAST([DIRECT SPLIT LATA SUMMARY COST] AS DECIMAL(18,2)),
                TRY_CAST([DIRECT BUNDLED CS COST] AS DECIMAL(18,2)),
                [COLLECTOR BDT],
                TRY_CAST([COLLECTOR COST] AS DECIMAL(18,2)),
                TRY_CAST([COLLECTOR ALLOCATION] AS DECIMAL(18,2)),
                TRY_CAST([ALLOCATED TOTAL CAPEX] AS DECIMAL(18,2)),
                [TYPE],
                [TERM],
                TRY_CAST([MRC] AS DECIMAL(18,2)),
                TRY_CAST([NRC] AS DECIMAL(18,2)),
                TRY_CAST([CIAC] AS DECIMAL(18,2)),
                TRY_CAST([NPV] AS DECIMAL(18,2)),
                [IRR],
                [PAYBACK],
                [ROUTING],
                [Speed],
                [DeskNum],
                TRY_CAST([Cycle Time(days)] AS DECIMAL(18,2)),
                TRY_CAST([Pre-discount CIAC (ATT)] AS DECIMAL(18,2)),
                TRY_CAST([Netex MRC] AS DECIMAL(18,2)),
                TRY_CAST([Netex NRC] AS DECIMAL(18,2))
            FROM [LZ].[FTTC_TRACKER_BACKUP_FLOW]
        
        COMMIT TRANSACTION FinalInsert

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION FinalInsert;

        THROW;

    END CATCH


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