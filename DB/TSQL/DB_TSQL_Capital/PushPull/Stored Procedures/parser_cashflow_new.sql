CREATE PROCEDURE [PushPull].[parser_cashflow_new]
AS
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION

    DROP TABLE IF EXISTS #Temp_LZ_abu_cls_with_cashflow_new;

    INSERT INTO [LOG].[Tracker]
        ([EVENTNAME]
        ,[EVENTSTART]
        ,[EVENTTYPE]
        ,[EVENTDESCRIPTION])
    VALUES
        ('[PushPull].[LZ_abu_cls_with_cashflow_new]'
        ,CAST(GETDATE() AS DATETIME)
        ,'STORE PROC'
        ,'Ingest abu_cls_with_cashflow_new.csv');

    SELECT MAX(EVENTID) AS LATESTID INTO #Temp_LZ_abu_cls_with_cashflow_new
    FROM [LOG].[Tracker];

    SET NOCOUNT ON;

    TRUNCATE TABLE [PushPull].[LZ_abu_cls_with_cashflow_new];

    BULK INSERT [PushPull].[LZ_abu_cls_with_cashflow_new]
    FROM 'd:\DataDump\abu_cls_with_cashflow_new.csv'

    WITH (FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE=65001, FIRSTROW=2);


    UPDATE [PushPull].[LZ_abu_cls_with_cashflow_new]
    SET project_number = REPLACE(project_number, '"', ''),
        numbre_of_cls = REPLACE(numbre_of_cls, '"', ''),
        increment_cf_0 = REPLACE(increment_cf_0, '"', ''),
        increment_cf_1 = REPLACE(increment_cf_1, '"', ''),
        increment_cf_2 = REPLACE(increment_cf_2, '"', ''),
        increment_cf_3 = REPLACE(increment_cf_3, '"', ''),
        increment_cf_4 = REPLACE(increment_cf_4, '"', ''),
        increment_cf_5 = REPLACE(increment_cf_5, '"', ''),
        increment_cf_6 = REPLACE(increment_cf_6, '"', ''),
        increment_cf_7 = REPLACE(increment_cf_7, '"', ''),
        increment_cf_8 = REPLACE(increment_cf_8, '"', ''),
        increment_cf_9 = REPLACE(increment_cf_9, '"', ''),
        increment_cf_10 = REPLACE(increment_cf_10, '"', '');

    UPDATE B
    SET B.EVENTEND = CAST(GETDATE() AS DATETIME)
    FROM LOG.Tracker B
    INNER JOIN #Temp_LZ_abu_cls_with_cashflow_new P
    ON B.EVENTID = P.LATESTID;

    DROP TABLE IF EXISTS #Temp_LZ_abu_cls_with_cashflow_new;

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@trancount > 0 ROLLBACK TRANSACTION
    EXEC usp_error_handler
    RETURN 55555
END CATCH;