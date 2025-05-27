
CREATE PROCEDURE [ExpenseForecast].[usp_Ingest_GLExpense]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.#Tracker_Temp_ExpenseForecast__usp_Ingest_GLExpense
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('ExpenseForecast.usp_Ingest_GL'
    ,CAST(GETDATE() AS DATETIME)
    ,'ETL'
    ,'Ingest')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.#Tracker_Temp_ExpenseForecast__usp_Ingest_GLExpense
FROM [LOG].[Tracker]

------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #LZ_GA_GL
CREATE TABLE #LZ_GA_GL (
	[TXCO] [varchar](10) NULL,
	[CTACCT] [varchar](50) NULL,
	[PROJ] [varchar](10) NULL,
	[SUBPRJ] [varchar](10) NULL,
	[MAINTSK] [varchar](10) NULL,
	[SUBTSK] [varchar](10) NULL,
	[MATRIX] [varchar](10) NULL,
	[AMOUNT] [varchar](25) NULL,
	[YEAR] [varchar](10) NULL,
	[MONTH] [varchar](10) NULL,
	[OPERAREA] [varchar](10) NULL,
	[JOURNAL] [varchar](15) NULL,
	[TXDESC] [varchar](200) NULL
)
--TRUNCATE TABLE [ExpenseForecast].[Raw_GLExpense]

BULK INSERT #LZ_GA_GL
FROM 'd:\DataDump\GLEXPENSE.csv'
WITH
(
FIELDTERMINATOR='|'
,Rowterminator = '0x0a'
,codepage=65001
,FIRSTROW=2
--,batchsize=500
--,format='csv'
--,fieldquote='"'
)


/*
BULK INSERT [ExpenseForecast].[Raw_GLExpense]
FROM 'd:\DataDump\GLEXPENSE2017.csv'
WITH
(
FIELDTERMINATOR='|'
,Rowterminator = '\n'
,codepage='65001'
,FIRSTROW=2
--,batchsize=500
--,format='csv'
,fieldquote='"'
)
*/

UPDATE #LZ_GA_GL
SET
TXCO=REPLACE(TXCO,'"',''),
CTACCT=REPLACE(CTACCT,'"',''),
PROJ=REPLACE(PROJ,'"',''),
SUBPRJ=REPLACE(SUBPRJ,'"',''),
MAINTSK=REPLACE(MAINTSK,'"',''),
SUBTSK=REPLACE(SUBTSK,'"',''),
MATRIX=REPLACE(MATRIX,'"',''),
AMOUNT=REPLACE(AMOUNT,'"',''),
YEAR=REPLACE(YEAR,'"',''),
MONTH=REPLACE(MONTH,'"',''),
OPERAREA=REPLACE(OPERAREA,'"',''),
JOURNAL=REPLACE(JOURNAL,'"',''),
TXDESC=REPLACE(TXDESC,'"','')

--SELECT TOP 100 * FROM #LZ_GA_GL

DELETE GL
FROM [ExpenseForecast].[Raw_GLExpense] GL
INNER JOIN #LZ_GA_GL LZ
ON GL.YEAR=LZ.YEAR
AND GL.MONTH=LZ.MONTH		

INSERT INTO [ExpenseForecast].[Raw_GLExpense]
(
[TXCO]
      ,[CTACCT]
      ,[PROJ]
      ,[SUBPRJ]
      ,[MAINTSK]
      ,[SUBTSK]
      ,[MATRIX]
      ,[AMOUNT]
      ,[YEAR]
      ,[MONTH]
      ,[OPERAREA]
      ,[JOURNAL]
      ,[TXDESC]
	  )
SELECT [TXCO]
      ,[CTACCT]
      ,[PROJ]
      ,[SUBPRJ]
      ,[MAINTSK]
      ,[SUBTSK]
      ,[MATRIX]
      ,[AMOUNT]
      ,[YEAR]
      ,[MONTH]
      ,[OPERAREA]
      ,[JOURNAL]
      ,[TXDESC]
FROM #LZ_GA_GL
DROP TABLE IF EXISTS  #LZ_GA_GL


		
-----------------------------------------------------------------------------------------
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.#Tracker_Temp_ExpenseForecast__usp_Ingest_GLExpense P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.#Tracker_Temp_ExpenseForecast__usp_Ingest_GLExpense

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH