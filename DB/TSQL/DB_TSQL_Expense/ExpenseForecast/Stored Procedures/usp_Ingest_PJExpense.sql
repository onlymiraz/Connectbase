
CREATE PROCEDURE [ExpenseForecast].[usp_Ingest_PJExpense]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.#Tracker_Temp_ExpenseForecast__usp_Ingest_PJExpense
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('ExpenseForecast.usp_Ingest_PJ'
    ,CAST(GETDATE() AS DATETIME)
    ,'ETL'
    ,'Ingest')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.#Tracker_Temp_ExpenseForecast__usp_Ingest_PJExpense
FROM [LOG].[Tracker]

------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #LZ_GA_PJ

CREATE TABLE #LZ_GA_PJ
([GACO#] [varchar](25) NULL,
	[GAACT] [varchar](255) NULL,
	[GAPRJ#] [varchar](25) NULL,
	[GAPRJS] [varchar](25) NULL,
	[GAPRJL] [varchar](25) NULL,
	[GAMTSK] [varchar](25) NULL,
	[GASTSK] [varchar](25) NULL,
	[GAMTRX] [varchar](25) NULL,
	[GASORC] [varchar](255) NULL,
	[GAPO#] [varchar](255) NULL,
	[GAPOLN] [varchar](25) NULL,
	[GARCPT] [varchar](255) NULL,
	[GARCP$] [varchar](25) NULL,
	[GALIN$] [varchar](25) NULL,
	[GARPT$] [varchar](25) NULL,
	[GATDTE] [varchar](25) NULL,
	[GAACTY] [varchar](25) NULL,
	[GAACTP] [varchar](25) NULL,
	[GAL2CD] [varchar](25) NULL,
	[GAEDTE] [varchar](25) NULL,
	[GAJTCD] [varchar](25) NULL,
	[GAOBUD] [varchar](25) NULL,
	[GAR1BD] [varchar](25) NULL,
	[GAR2BD] [varchar](25) NULL,
	[GALDSC] [varchar](255) NULL,
	[GA1COD] [varchar](25) NULL,
	[GAOPRA] [varchar](25) NULL,
	[GAINV#] [varchar](255) NULL,
	[GAIDTE] [varchar](25) NULL,
	[GAVEND] [varchar](25) NULL,
	[GAVNNM] [varchar](255) NULL,
	[GACHS2] [varchar](25) NULL,
	[GAVOUC] [varchar](25) NULL,
	[GAREF] [varchar](255) NULL,
	[GADESC] [varchar](255) NULL,
	[GAEXCH] [varchar](255) NULL,
	[GAPRJT] [varchar](255) NULL,
	[GAFUNC] [varchar](255) NULL,
	[STATE] [varchar](255) NULL,
	[HRS] [varchar](25) NULL,
	[QTY] [varchar](25) NULL,
	[UNITCST] [nvarchar](max) NULL)
--TRUNCATE TABLE [ExpenseForecast].[Raw_PJExpense]
BULK INSERT #LZ_GA_PJ
FROM 'd:\LZ\Capital\PJEXPENSE.csv'
WITH
(
FIELDTERMINATOR='|'
,Rowterminator = '0x0a'
,codepage=65001
--,batchsize=500
--,format='csv'
--,fieldquote='"'
)

/*
BULK INSERT [ExpenseForecast].[Raw_PJExpense]
FROM 'd:\DataDump\PJEXPENSE2017.csv'
WITH
(
FIELDTERMINATOR='|'
,Rowterminator = '\n'
,codepage='65001'
--,batchsize=500
--,format='csv'
,fieldquote='"'
)
*/


UPDATE #LZ_GA_PJ
SET
[GACO#] = REPLACE([GACO#],'"',''),
[GAACT] = REPLACE([GAACT],'"',''),
[GAPRJ#] = REPLACE([GAPRJ#],'"',''),
[GAPRJS] = REPLACE([GAPRJS],'"',''),
[GAPRJL] = REPLACE([GAPRJL],'"',''),
[GAMTSK] = REPLACE([GAMTSK],'"',''),
[GASTSK] = REPLACE([GASTSK],'"',''),
[GAMTRX] = REPLACE([GAMTRX],'"',''),
[GASORC] = REPLACE([GASORC],'"',''),
[GAPO#] = REPLACE([GAPO#],'"',''),
[GAPOLN] = REPLACE([GAPOLN],'"',''),
[GARCPT] = REPLACE([GARCPT],'"',''),
[GARCP$] = REPLACE([GARCP$],'"',''),
[GALIN$] = REPLACE([GALIN$],'"',''),
[GARPT$] = REPLACE([GARPT$],'"',''),
[GATDTE] = REPLACE([GATDTE],'"',''),
[GAACTY] = REPLACE([GAACTY],'"',''),
[GAACTP] = REPLACE([GAACTP],'"',''),
[GAL2CD] = REPLACE([GAL2CD],'"',''),
[GAEDTE] = REPLACE([GAEDTE],'"',''),
[GAJTCD] = REPLACE([GAJTCD],'"',''),
[GAOBUD] = REPLACE([GAOBUD],'"',''),
[GAR1BD] = REPLACE([GAR1BD],'"',''),
[GAR2BD] = REPLACE([GAR2BD],'"',''),
[GALDSC] = REPLACE([GALDSC],'"',''),
[GA1COD] = REPLACE([GA1COD],'"',''),
[GAOPRA] = REPLACE([GAOPRA],'"',''),
[GAINV#] = REPLACE([GAINV#],'"',''),
[GAIDTE] = REPLACE([GAIDTE],'"',''),
[GAVEND] = REPLACE([GAVEND],'"',''),
[GAVNNM] = REPLACE([GAVNNM],'"',''),
[GACHS2] = REPLACE([GACHS2],'"',''),
[GAVOUC] = REPLACE([GAVOUC],'"',''),
[GAREF] = REPLACE([GAREF],'"',''),
[GADESC] = REPLACE([GADESC],'"',''),
[GAEXCH] = REPLACE([GAEXCH],'"',''),
[GAPRJT] = REPLACE([GAPRJT],'"',''),
[GAFUNC] = REPLACE([GAFUNC],'"',''),
[STATE] = REPLACE([STATE],'"',''),
[HRS] = REPLACE([HRS],'"',''),
[QTY] = REPLACE([QTY],'"',''),
[UNITCST] = REPLACE([UNITCST],'"','')



DELETE PJ
FROM [ExpenseForecast].[Raw_PJExpense] PJ
INNER JOIN #LZ_GA_PJ LZ
ON PJ.GAACTY=LZ.GAACTY
AND PJ.GAACTP=LZ.GAACTP

INSERT INTO [ExpenseForecast].[Raw_PJExpense]
(
[GACO#]
      ,[GAACT]
      ,[GAPRJ#]
      ,[GAPRJS]
      ,[GAPRJL]
      ,[GAMTSK]
      ,[GASTSK]
      ,[GAMTRX]
      ,[GASORC]
      ,[GAPO#]
      ,[GAPOLN]
      ,[GARCPT]
      ,[GARCP$]
      ,[GALIN$]
      ,[GARPT$]
      ,[GATDTE]
      ,[GAACTY]
      ,[GAACTP]
      ,[GAL2CD]
      ,[GAEDTE]
      ,[GAJTCD]
      ,[GAOBUD]
      ,[GAR1BD]
      ,[GAR2BD]
      ,[GALDSC]
      ,[GA1COD]
      ,[GAOPRA]
      ,[GAINV#]
      ,[GAIDTE]
      ,[GAVEND]
      ,[GAVNNM]
      ,[GACHS2]
      ,[GAVOUC]
      ,[GAREF]
      ,[GADESC]
      ,[GAEXCH]
      ,[GAPRJT]
      ,[GAFUNC]
      ,[STATE]
      ,[HRS]
      ,[QTY]
      ,[UNITCST]
)
SELECT [GACO#]
      ,[GAACT]
      ,[GAPRJ#]
      ,[GAPRJS]
      ,[GAPRJL]
      ,[GAMTSK]
      ,[GASTSK]
      ,[GAMTRX]
      ,[GASORC]
      ,[GAPO#]
      ,[GAPOLN]
      ,[GARCPT]
      ,[GARCP$]
      ,[GALIN$]
      ,[GARPT$]
      ,[GATDTE]
      ,[GAACTY]
      ,[GAACTP]
      ,[GAL2CD]
      ,[GAEDTE]
      ,[GAJTCD]
      ,[GAOBUD]
      ,[GAR1BD]
      ,[GAR2BD]
      ,[GALDSC]
      ,[GA1COD]
      ,[GAOPRA]
      ,[GAINV#]
      ,[GAIDTE]
      ,[GAVEND]
      ,[GAVNNM]
      ,[GACHS2]
      ,[GAVOUC]
      ,[GAREF]
      ,[GADESC]
      ,[GAEXCH]
      ,[GAPRJT]
      ,[GAFUNC]
      ,[STATE]
      ,[HRS]
      ,[QTY]
      ,[UNITCST]
FROM #LZ_GA_PJ



--QA
--select DISTINCT GAACTY, GAACTP from #LZ_GA_PJ
--select DISTINCT GAACTY, GAACTP from [ExpenseForecast].[Raw_PJExpense] ORDER BY GAACTY, GAACTP
--select COUNT(*) from #LZ_GA_PJ
--select COUNT(*) From [ExpenseForecast].[Raw_PJExpense] where GAACTY='2022' and GAACTP='10'

DROP TABLE IF EXISTS #LZ_GA_PJ

		
-----------------------------------------------------------------------------------------
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.#Tracker_Temp_ExpenseForecast__usp_Ingest_PJExpense P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.#Tracker_Temp_ExpenseForecast__usp_Ingest_PJExpense

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH