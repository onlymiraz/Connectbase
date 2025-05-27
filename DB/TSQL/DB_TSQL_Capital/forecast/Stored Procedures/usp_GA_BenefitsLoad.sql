
CREATE PROCEDURE [forecast].[usp_GA_BenefitsLoad]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION

DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_GA_BenefitsLoad
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_GA_BenefitsLoad]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_GA_BenefitsLoad
FROM [LOG].[Tracker]



 update webapp.ga
 set GAMTRX='111'
 where (GAMTRX='999'
 and (GALDSC like '%BENE%'
 OR GALDSC like '%bene%'
 or GALDSC like '%Bene%'))
 or GAMTRX='997'


----drop temp tables
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id=OBJECT_ID(N'[DBO].[GA2]') AND type in (N'U'))
--DROP TABLE [DBO].[GA2]

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id=OBJECT_ID(N'[DBO].[GA3]') AND type in (N'U'))
--DROP TABLE [DBO].[GA3]


----Bring current year data from history to temp	
--SELECT cast(gaprj# as int) as ProjectNumber
--   ,cast(gaprjs as smallint) as SubProjectNumber
--   ,cast([GAMTRX] as smallint) as GAMTRX
--   ,GALDSC
--   ,cast([GARPT$] as FLOAT) as [GARPT$]
--   ,cast([GAACTY] as int) AS [GAACTY]
--   ,cast([GAACTP] as tinyint) AS [GAACTP]
--into dbo.GA2
-- FROM [history].[GALisa]
-- where [history].[GALisa].GAACTY='2021'



----Bring Cost Code 999 Benefits Load AND Cost Code 997 from temp to new temp table
--SELECT distinct ProjectNumber, SubProjectNumber, GAACTY, GAACTP, SUM(CAST(GARPT$ AS MONEY)) AS AMT
-- INTO DBO.GA3
-- FROM [dbo].[GA2]
-- where (GAMTRX=999
-- and (GALDSC like '%BENE%'
-- OR GALDSC like '%bene%'
-- or GALDSC like '%Bene%'))
-- or GAMTRX=997
-- GROUP BY ProjectNumber, SubProjectNumber, GAACTY, GAACTP




----Direct 999 - add values from new temp table to forecast's GAdirect for Cost Code 999 Benefits Load and Cost Code 997
--UPDATE D SET D.[January]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=1
--UPDATE D SET D.[February]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=2
--UPDATE D SET D.[March]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=3
--UPDATE D SET D.[April]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=4
--UPDATE D SET D.[May]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=5
--UPDATE D SET D.[June]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=6
--UPDATE D SET D.[July]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=7
--UPDATE D SET D.[August]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=8
--UPDATE D SET D.[September]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=9
--UPDATE D SET D.[October]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=10
--UPDATE D SET D.[November]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=11
--UPDATE D SET D.[December]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=12



--UPDATE D SET D.[January]=D.[January]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=1
--UPDATE D SET D.[February]=D.[February]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=2
--UPDATE D SET D.[March]=D.[March]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=3
--UPDATE D SET D.[April]=D.[April]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=4
--UPDATE D SET D.[May]=D.[May]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=5
--UPDATE D SET D.[June]=D.[June]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=6
--UPDATE D SET D.[July]=D.[July]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=7
--UPDATE D SET D.[August]=D.[August]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=8
--UPDATE D SET D.[September]=D.[September]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=9
--UPDATE D SET D.[October]=D.[October]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=10
--UPDATE D SET D.[November]=D.[November]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=11
--UPDATE D SET D.[December]=D.[December]+G3.AMT FROM forecast.GrossAddsDirect AS D, DBO.GA3 AS G3 WHERE D.ProjectNumber=G3.ProjectNumber AND D.SubprojectNumber=G3.SubProjectNumber AND D.[Year]=G3.GAACTY AND G3.GAACTP=12

-----------------------------------------------------------------------------------------------------

----InDirect 999 - subtract values from new temp table to forecast's GAdirect for Cost Code 999 Benefits Load and Cost Code 997
--UPDATE I SET I.[January]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=1
--UPDATE I SET I.[February]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=2
--UPDATE I SET I.[March]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=3
--UPDATE I SET I.[April]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=4
--UPDATE I SET I.[May]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=5
--UPDATE I SET I.[June]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=6
--UPDATE I SET I.[July]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=7
--UPDATE I SET I.[August]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=8
--UPDATE I SET I.[September]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=9
--UPDATE I SET I.[October]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=10
--UPDATE I SET I.[November]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=11
--UPDATE I SET I.[December]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=12



--UPDATE I SET I.[January]=I.[JANUARY]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=1
--UPDATE I SET I.[February]=I.[February]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=2
--UPDATE I SET I.[March]=I.[March]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=3
--UPDATE I SET I.[April]=I.[April]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=4
--UPDATE I SET I.[May]=I.[May]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=5
--UPDATE I SET I.[June]=I.[June]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=6
--UPDATE I SET I.[July]=I.[July]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=7
--UPDATE I SET I.[August]=I.[August]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=8
--UPDATE I SET I.[September]=I.[September]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=9
--UPDATE I SET I.[October]=I.[October]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=10
--UPDATE I SET I.[November]=I.[November]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=11
--UPDATE I SET I.[December]=I.[December]-G3.AMT FROM forecast.GrossAddsIndirect AS I, DBO.GA3 AS G3 WHERE I.ProjectNumber=G3.ProjectNumber AND I.SubprojectNumber=G3.SubProjectNumber AND I.[Year]=G3.GAACTY AND G3.GAACTP=12


----drop temp tables
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id=OBJECT_ID(N'[DBO].[GA2]') AND type in (N'U'))
--DROP TABLE [DBO].[GA2]

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id=OBJECT_ID(N'[DBO].[GA3]') AND type in (N'U'))
--DROP TABLE [DBO].[GA3]


UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_GA_BenefitsLoad P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_GA_BenefitsLoad


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH

