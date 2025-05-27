Create procedure [Brownfield].[Parser_JHFFTRDCBX]
AS
    SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
    BEGIN TRANSACTION

 

    DROP TABLE IF EXISTS #Temp_Parser_JHFFTRDCBX
    INSERT INTO [LOG].[Tracker]
        ([EVENTNAME]
        ,[EVENTSTART]
        ,[EVENTTYPE]
        ,[EVENTDESCRIPTION])
    VALUES
    ('[Brownfield].[Parser_JHFFTRDCBX]'
        ,CAST(GETDATE() AS DATETIME)
        ,'STORE PROC'
        ,'Ingest JHFFTRDCBX.csv')

 

    SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Parser_JHFFTRDCBX
    FROM [LOG].[Tracker]

    SET NOCOUNT ON;

 

    truncate table [Brownfield].[LZ_JHFFTRDCBX]

 

    bulk insert [Brownfield].[LZ_JHFFTRDCBX] from 'd:\DataDump\JHFFTRDCBX.csv'
    with (fieldterminator='|', rowterminator='0x0a', codepage=65001, FIRSTROW=2)

 

    update [Brownfield].[LZ_JHFFTRDCBX]
    set     LINEJUSTIFICATCODE = REPLACE(LINEJUSTIFICATCODE, '"', ''),
    PROJECTMASTERNUMBR = REPLACE(PROJECTMASTERNUMBR, '"', ''),
    LINESUB_PROJECT# = REPLACE(LINESUB_PROJECT#, '"', ''),
    LINESTATEABBRV = REPLACE(LINESTATEABBRV, '"', ''),
    COSTCODE = REPLACE(COSTCODE, '"', ''),
    SUMLINBUD = REPLACE(SUMLINBUD, '"', '')    


        
    UPDATE B
    SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
    FROM LOG.Tracker B
    INNER JOIN #Temp_Parser_JHFFTRDCBX P
    ON B.EVENTID = P.LATESTID
    DROP TABLE IF EXISTS #Temp_Parser_JHFFTRDCBX

 

COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@trancount > 0 ROLLBACK TRANSACTION
    EXEC usp_error_handler
    RETURN 55555
END CATCH