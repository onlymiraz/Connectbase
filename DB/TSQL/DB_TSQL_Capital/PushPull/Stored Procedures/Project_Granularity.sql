CREATE PROCEDURE [PushPull].[Project_Granularity]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Project_Granularity
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])

	VALUES
	('[PushPull].[Project_Granularity]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Create Project_Granularity Report')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Project_Granularity
	FROM [LOG].[Tracker]

	SET NOCOUNT ON;

	truncate table [PushPull].[PushPull_Project_Gran]
	
	;with FP as  (
		select distinct fff.projectnumber,fff.[State],fff.ApprovalCode,r.Region,ga.GAEXCH Wirecenter,fff.JustificationCode
		from dbo.FFFIELDS fff
			left join history.galisa ga on fff.projectnumber = ga.gaprj#
			left join brownfield.Regions r on fff.[State] = r.[State]

		where fff.ProjectStatusCode != 'CX' and (CloseDate = '0' or CloseDate like '%23')

		group by fff.projectnumber,fff.[State],fff.ApprovalCode,r.Region,ga.GAEXCH,fff.JustificationCode
		order by fff.ProjectNumber asc offset 0 rows
		)
			
	Insert into [PushPull].[PushPull_Project_Gran]
	
	select * 
	from FP
	
	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Project_Granularity G
	ON B.EVENTID = G.LATESTID

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH