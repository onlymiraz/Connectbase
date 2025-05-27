CREATE PROCEDURE [PushPull].[Subproject_Granularity]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Subproject_Granularity
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])

	VALUES
	('[PushPull].[Subproject_Granularity]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Create Subproject_Granularity Report')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Subproject_Granularity
	FROM [LOG].[Tracker]

	SET NOCOUNT ON;

	truncate table [PushPull].[PushPull_Subproj_Gran]
	
	;with SP as  (
		select ProjectNumber,fff.SubprojectNumber,ClassOfPlant,JustificationCode,ProjectStatusCode,case when v.[Estimated In Service Date] is null then 0 else v.[Estimated In Service Date] end as EstimatedInServiceDate,case when v.WOAssignedVendor is null then ' ' else v.WOAssignedVendor end as WOAssignedVendor,case when o.origbudgdirect is null then 0.00 else sum(cast(o.OrigBudgDirect as float)) end as OriginalProjectBudgetDirect
		from dbo.FFFIELDS fff
		
		left join history.galisa ga on fff.projectnumber = ga.gaprj#
		left join PushPull.OriginalBudget o on fff.ProjectNumber = o.ProjectMasterNumbr and fff.SubprojectNumber = o.subprojectnumber
		left join dbo.Varasset_FPStatus v on fff.ProjectNumber = v.Project and fff.SubprojectNumber = v.Subproject
		
	where fff.ProjectStatusCode != 'CX' and (CloseDate = '0' or CloseDate like '%23')

	group by fff.ProjectNumber, fff.SubprojectNumber, fff.EstimatedCompleteDate,fff.ClassOfPlant, fff.JustificationCode, fff.ProjectStatusCode, fff.ApprovalCode, fff.CloseDate, o.OrigBudgDirect, v.[Estimated In Service Date],v.WOAssignedVendor
	order by fff.ProjectNumber, fff.SubprojectNumber asc offset 0 rows
		)

	
	Insert into PushPull_Subproj_Gran
	
	select * 
	from SP
	

	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Subproject_Granularity G
	ON B.EVENTID = G.LATESTID

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH