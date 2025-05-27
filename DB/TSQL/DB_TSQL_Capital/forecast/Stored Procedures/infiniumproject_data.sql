CREATE PROCEDURE [forecast].[infiniumproject_data]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Createinfiniumproject_data
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])

	VALUES
	('[forecast].[infiniumproject_data]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Create infiniumproject_data')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Createinfiniumproject_data
	FROM [LOG].[Tracker]	
	SET NOCOUNT ON;

	TRUNCATE TABLE [forecast].[infiniumprojectdata]

	INSERT INTO [forecast].[infiniumprojectdata]
	SELECT  DISTINCT   j.[JustificationCode], j.[ProjectNumber], j.[SubprojectNumber], j.AuthorizedDirect, j.PriorYearsSpendTotal + j.GrossAddsDirect spent$, j.ProjectStatusCode, NULL
	FROM [forecast].[ForecastExport] j
	LEFT JOIN [dbo].[BUDGETLINE] b ON j.subprojectNumber = b.SubprojectNumber and j.projectnumber = b.ProjectNumber
	LEFT JOIN [history].[GALisa] c ON j.[ProjectNumber]= c.GAPRJ# AND j.[SubprojectNumber]= c.GAPRJS
	Where j.ProjectStatusCode = 'cl' AND (j.JustificationCode=10 or j.JustificationCode=38 or j.JustificationCode=68)
	AND (GAMTRX != '999' AND GAMTRX != '998' AND GAMTRX != '997' AND GAMTRX != '996' AND GAMTRX != '995' AND GAMTRX != '994' AND GAMTRX != '993' AND GAMTRX != '992' AND GAMTRX != '991' AND GAMTRX != '990' AND GAMTRX != '427')
	ORDER BY j.[ProjectNumber] DESC,  j.[SubprojectNumber] ASC

UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Createinfiniumproject_data M
	ON B.EVENTID = M.LATESTID
	DROP TABLE IF EXISTS #Temp_Createinfiniumproject_data

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH