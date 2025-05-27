
CREATE PROCEDURE [forecast].[usp_GA_reset]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION

DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_GA_reset
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_GA_reset]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_GA_reset
FROM [LOG].[Tracker]


----Direct
UPDATE D SET D.[January]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=1
UPDATE D SET D.[February]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=2
UPDATE D SET D.[March]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=3
UPDATE D SET D.[April]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=4
UPDATE D SET D.[May]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=5
UPDATE D SET D.[June]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=6
UPDATE D SET D.[July]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=7
UPDATE D SET D.[August]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=8
UPDATE D SET D.[September]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=9
UPDATE D SET D.[October]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=10
UPDATE D SET D.[November]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=11
UPDATE D SET D.[December]=0 FROM forecast.GrossAddsDirect AS D, DBO.GA WHERE D.ProjectNumber=GA.ProjectNumber AND D.SubprojectNumber=GA.SubProjectNumber AND D.[Year]=GA.GAACTY AND GA.GAACTP=12


----InDirect
UPDATE I SET I.[January]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=1
UPDATE I SET I.[February]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=2
UPDATE I SET I.[March]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=3
UPDATE I SET I.[April]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=4
UPDATE I SET I.[May]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=5
UPDATE I SET I.[June]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=6
UPDATE I SET I.[July]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=7
UPDATE I SET I.[August]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=8
UPDATE I SET I.[September]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=9
UPDATE I SET I.[October]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=10
UPDATE I SET I.[November]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=11
UPDATE I SET I.[December]=0 FROM forecast.GrossAddsIndirect AS I, DBO.GA WHERE I.ProjectNumber=GA.ProjectNumber AND I.SubprojectNumber=GA.SubProjectNumber AND I.[Year]=GA.GAACTY AND GA.GAACTP=12

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_GA_reset P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_GA_reset


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH