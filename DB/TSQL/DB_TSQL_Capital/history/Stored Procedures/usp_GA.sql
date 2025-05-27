
CREATE PROCEDURE [history].[usp_GA]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
DROP TABLE IF EXISTS LOG.Tracker_Temp_history__usp_GA
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[history].[usp_GA]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_history__usp_GA
FROM [LOG].[Tracker]

/**	
TRUNCATE TABLE webapp.ga
bulk insert webapp.GA
FROM '\\nspinfwcipp01\Capital_Management\Capital Management Application\Queries\Gross Adds Nightly.txt'

delete from webapp.ga
where GACO# LIKE '%Company%'

update webapp.ga
set GARPT$ = 0
where GARPT$ LIKE '% -   %'

update webapp.ga
set GARPT$ = REPLACE(GARPT$, ',', '')


update webapp.ga
set GARPT$ = REPLACE(GARPT$, '"', '')

DELETE FROM webapp.ga
where GAPRJ# = 'GAPRJ#'
**/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id=OBJECT_ID(N'[webapp].[GA2]') AND type in (N'U'))
DROP TABLE webapp.[GA2]


select distinct GAACTY,GAACTP
into webapp.ga2
from webapp.ga


DELETE G
FROM history.GALisa G
INNER JOIN webapp.ga2 G2
ON G.GAACTY=G2.GAACTY
AND G.GAACTP=G2.GAACTP
WHERE G.GAACTY=G2.GAACTY
AND G.GAACTP=G2.GAACTP

INSERT INTO [history].[GALisa]
           ([GACO#]
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
           ,[UNITCST])
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
FROM webapp.ga



IF EXISTS (SELECT * FROM sys.objects WHERE object_id=OBJECT_ID(N'[webapp].[GA2]') AND type in (N'U'))
DROP TABLE webapp.[GA2]
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_history__usp_GA P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_history__usp_GA

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
