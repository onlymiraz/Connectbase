CREATE PROCEDURE CB_MS.usp_TBL_CB_MS_COMBINED
/*
	-- Add any parameters for the stored procedure here
	@var1 int,
	@var2 int
*/
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
        'CB_MS.usp_TBL_CB_MS_COMBINED',
        CAST(GETDATE() AS DATETIME),
        'STORE PROC',
        'SINGLE_INGESTION'
    )

    SET @EVENTID = SCOPE_IDENTITY();

	BEGIN TRANSACTION

    ;WITH RankedSource AS (
        SELECT 
            ID,
            LOGIN_ID,
            ROUTE_NAME,
            REQUESTING_COMPANY,
            CLIENT_COMPANY,
            CCNA_X,
            ADDRESS,
            CITY,
            STATE,
            ZIP,
            COUNTY,
            COUNTRY,
            USER_COMPANY,
            TARGET_COMPANY_ID,
            TARGET_COMPANY,
            REQUEST_DATE,
            RESULT,
            SERVICENAME,
            SERVICE_TYPE,
            ERROR_MESSAGE,
            TERMS,
            FILE_NAME,
            UPDATED_DT,
            ROW_NUMBER() OVER (
                PARTITION BY ID, ADDRESS, CITY, STATE, ZIP
                ORDER BY 
                    CASE 
                        WHEN ERROR_MESSAGE = 'Ready' THEN 1
                        WHEN ERROR_MESSAGE = 'Expired' THEN 2
                        WHEN ERROR_MESSAGE = 'No Solution' THEN 3
                        WHEN ERROR_MESSAGE = 'ICB Needed' THEN 4
                        WHEN ERROR_MESSAGE = 'Processing' THEN 5
                        WHEN ERROR_MESSAGE = 'Abandoned' THEN 6
                        WHEN ERROR_MESSAGE = 'Error' THEN 7
                        WHEN ERROR_MESSAGE = 'Not In State' THEN 8
                        WHEN ERROR_MESSAGE = 'Remove' THEN 9
                        WHEN ERROR_MESSAGE = 'SPR Needed' THEN 10
                        WHEN ERROR_MESSAGE = 'Aborted' THEN 11
                        ELSE 12
                    END
            ) AS RN
        FROM (
            SELECT DISTINCT
                RFQ_ AS ID,
                NULL AS [LOGIN_ID],
                NULL AS [ROUTE_NAME],
                AGENT_COMPANY AS [REQUESTING_COMPANY],
                CLIENT_COMPANY,
                CCNA_X,
                ADDRESS,
                CITY,
                STATE,
                ZIP,
                NULL AS [COUNTY],
                NULL AS [COUNTRY],
                NULL AS [USER_COMPANY],
                NULL AS [TARGET_COMPANY_ID],
                NULL AS [TARGET_COMPANY],
                CAST(QUOTE_DATE AS DATETIME2) AS REQUEST_DATE,
                NULL AS RESULT,
                PRODUCT_TYPE AS SERVICENAME,
                SERVICE_TYPE,
                SERVICE_STATUS AS ERROR_MESSAGE,
                TERMS,
                'MASTERSTREAM' AS FILE_NAME,
                CAST(GETDATE() AS DATE) AS UPDATED_DT
            FROM WAD_PRD_INTEGRATION.LZ_PY.Masterstream_Quotes_Daily
            WHERE NOT (RFQ_ = '4039110197' AND SERVICE_STATUS = 'processing')

            UNION

            SELECT 
                ID,
                [LOGIN_ID],
                [ROUTE_NAME],
                [REQUESTING_COMPANY],
                NULL AS CLIENT_COMPANY,
                NULL AS CCNA_X,
                [ADDRESS],
                [CITY],
                [STATE],
                ZIP,
                [COUNTY],
                [COUNTRY],
                [USER_COMPANY],
                [TARGET_COMPANY_ID],
                [TARGET_COMPANY],
                CAST(REQUEST_DATE AS DATETIME2) AS REQUEST_DATE,
                RESULT,
                SERVICENAME,
                NULL AS SERVICE_TYPE,
                ERROR_MESSAGE,
                NULL AS TERMS,
                FILE_NAME,
                CAST(GETDATE() AS DATE) AS UPDATED_DT
            FROM WAD_PRD_INTEGRATION.LZ_PY.CB_FRONTIER_DEMAND_ENGINE_ACTIVITIES_750

            UNION

            SELECT
                ID,
                [LOGIN_ID],
                [ROUTE_NAME],
                [REQUESTING_COMPANY],
                NULL AS CLIENT_COMPANY,
                NULL AS CCNA_X,
                [ADDRESS],
                [CITY],
                [STATE],
                ZIP,
                [COUNTY],
                [COUNTRY],
                [USER_COMPANY],
                [TARGET_COMPANY_ID],
                [TARGET_COMPANY],
                CAST(REQUEST_DATE AS DATETIME2) AS REQUEST_DATE,
                RESULT,
                SERVICENAME,
                NULL AS SERVICE_TYPE,
                ERROR_MESSAGE,
                NULL AS TERMS,
                FILE_NAME,
                CAST(GETDATE() AS DATE) AS UPDATED_DT
            FROM WAD_PRD_INTEGRATION.LZ_PY.CB_FRONTIER_DEMAND_ENGINE_ACTIVITIES_819
        ) AS A
    )
    MERGE INTO CB_MS.TBL_CB_MS_COMBINED AS TARGET
    USING (
        SELECT * FROM RankedSource WHERE RN = 1
    ) AS SOURCE
    ON TARGET.ID = SOURCE.ID
    AND COALESCE(TARGET.ADDRESS, 'XX') = COALESCE(SOURCE.ADDRESS, 'XX')
    AND COALESCE(TARGET.CITY, 'XX') = COALESCE(SOURCE.CITY, 'XX')
    AND COALESCE(TARGET.STATE, 'XX') = COALESCE(SOURCE.STATE, 'XX')
    AND COALESCE(TARGET.ZIP, 'XX') = COALESCE(SOURCE.ZIP, 'XX')
    AND COALESCE(TARGET.SERVICENAME, 'XX') = COALESCE(SOURCE.SERVICENAME, 'XX')
    AND COALESCE(TARGET.SERVICE_TYPE, 'XX') = COALESCE(SOURCE.SERVICE_TYPE, 'XX')
    WHEN MATCHED THEN 
        UPDATE SET
            TARGET.ID = SOURCE.ID,
            TARGET.LOGIN_ID = SOURCE.LOGIN_ID,
            TARGET.ROUTE_NAME = SOURCE.ROUTE_NAME,
            TARGET.REQUESTING_COMPANY = SOURCE.REQUESTING_COMPANY,
            TARGET.CLIENT_COMPANY = SOURCE.CLIENT_COMPANY,
            TARGET.CCNA_X = SOURCE.CCNA_X,
            TARGET.ADDRESS = SOURCE.ADDRESS,
            TARGET.CITY = SOURCE.CITY,
            TARGET.STATE = SOURCE.STATE,
            TARGET.ZIP = SOURCE.ZIP,
            TARGET.COUNTY = SOURCE.COUNTY,
            TARGET.COUNTRY = SOURCE.COUNTRY,
            TARGET.USER_COMPANY = SOURCE.USER_COMPANY,
            TARGET.TARGET_COMPANY_ID = SOURCE.TARGET_COMPANY_ID,
            TARGET.TARGET_COMPANY = SOURCE.TARGET_COMPANY,
            TARGET.REQUEST_DATE = SOURCE.REQUEST_DATE,
            TARGET.RESULT = SOURCE.RESULT,
            TARGET.SERVICENAME = SOURCE.SERVICENAME,
            TARGET.SERVICE_TYPE = SOURCE.SERVICE_TYPE,
            TARGET.ERROR_MESSAGE = SOURCE.ERROR_MESSAGE,
            TARGET.TERMS = SOURCE.TERMS,
            TARGET.FILE_NAME = SOURCE.FILE_NAME,
            TARGET.UPDATED_DT = SOURCE.UPDATED_DT
    WHEN NOT MATCHED BY TARGET THEN 
        INSERT (
            ID,
            LOGIN_ID,
            ROUTE_NAME,
            REQUESTING_COMPANY,
            CLIENT_COMPANY,
            CCNA_X,
            ADDRESS,
            CITY,
            STATE,
            ZIP,
            COUNTY,
            COUNTRY,
            USER_COMPANY,
            TARGET_COMPANY_ID,
            TARGET_COMPANY,
            REQUEST_DATE,
            RESULT,
            SERVICENAME,
            SERVICE_TYPE,
            ERROR_MESSAGE,
            TERMS,
            FILE_NAME,
            UPDATED_DT
        )
        VALUES (
            SOURCE.ID,
            SOURCE.LOGIN_ID,
            SOURCE.ROUTE_NAME,
            SOURCE.REQUESTING_COMPANY,
            SOURCE.CLIENT_COMPANY,
            SOURCE.CCNA_X,
            SOURCE.ADDRESS,
            SOURCE.CITY,
            SOURCE.STATE,
            SOURCE.ZIP,
            SOURCE.COUNTY,
            SOURCE.COUNTRY,
            SOURCE.USER_COMPANY,
            SOURCE.TARGET_COMPANY_ID,
            SOURCE.TARGET_COMPANY,
            SOURCE.REQUEST_DATE,
            SOURCE.RESULT,
            SOURCE.SERVICENAME,
            SOURCE.SERVICE_TYPE,
            SOURCE.ERROR_MESSAGE,
            SOURCE.TERMS,
            SOURCE.FILE_NAME,
            SOURCE.UPDATED_DT
        );
		
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
GO

