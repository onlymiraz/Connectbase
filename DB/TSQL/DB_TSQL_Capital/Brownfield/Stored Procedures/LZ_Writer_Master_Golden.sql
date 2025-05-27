CREATE PROCEDURE [Brownfield].[LZ_Writer_Master_Golden]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_LZ_Writer_Master_Golden
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])

	VALUES
	('[Brownfield].[MasterGoldenReport]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Create Master Golden report')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_LZ_Writer_Master_Golden
	FROM [LOG].[Tracker]

	SET NOCOUNT ON;

	truncate table [Brownfield].[MasterGoldenReport]
DECLARE @YrPrevious DATE
DECLARE @YrCurrent DATE
	SET @YrPrevious = '2023-01-09'
	SET @YrCurrent = '2023-01-09'
  
;with VarassetVendor as (
		select distinct v.Project, v.WOAssignedVendor as Vendor
		from dbo.Varasset_FPStatus v
		join dbo.FFFIELDS f on f.ProjectNumber = v.Project
		where f.JustificationCode = 5 and v.WOAssignedVendor is not null
		)
	,BulkReelContractor as (
		select * from VarassetVendor
		UNION ALL
		select distinct br.PROJECTNumber, br.Contractor Vendor
		from [Brownfield].[LZ_BulkReelUsage] br
		join dbo.FFFIELDS f on f.ProjectNumber = br.PROJECTNumber
		where f.JustificationCode = 5 and br.Contractor is not null
		and br.ProjectNumber NOT IN (Select Project from VarassetVendor)
		)
	,Ex AS (SELECT distinct GAEXCH
		from [history].[GALisa]
		JOIN [dbo].[FFFIELDS] fff on GAEXCH = fff.exchangenumber
		Group By GAEXCH
			)
	,EMC AS (SELECT EMC, Project, Sub
		from brownfield.BrownfieldMatrixEMC
			)
	,Orig AS (select jc5.proj#, jc5.sub#,
		(cast(jc5.origBdgt$ as float)) OriginalAuthorizedTotal
		from [Brownfield].[LZ_JMJC5FLDSF] JC5
		--LEFT JOIN [Brownfield].[LZ_JMAUTHDTLF] Auth on JC5.proj# = Auth.proj# and JC5.sub# = Auth.sub#
		group by jc5.proj#, jc5.sub#, jc5.OrigBdgt$
)
,CurrTotal AS (select jc5.proj#, jc5.sub#,
		CASE
		WHEN SUM(CAST(jc5.RevBdgt$2 AS FLOAT)) > 0 THEN SUM(CAST(jc5.RevBdgt$2 AS FLOAT))
		WHEN SUM(CAST(jc5.RevBdgt$1 AS FLOAT)) > 0 THEN SUM(CAST(jc5.RevBdgt$1 AS FLOAT))
		ELSE SUM(CAST(jc5.OrigBdgt$ AS FLOAT)) end as CurrentAuthorizedTotal
		from [Brownfield].[LZ_JMJC5FLDSF] JC5
		group by JC5.proj#, jc5.sub#
		)
	,OrigID AS (
		select auth.proj#, auth.sub#,
		sum(cast(auth.Budget$ as float)) OriginalAuthorizedIndirect
		FROM [Brownfield].[LZ_JMAUTHDTLF] Auth
		WHERE LINEDESCRIPTION != 'ADDL AUTH$'                                 
		group by auth.proj#, auth.sub#
			)
	,CurrID 
		AS (
		select auth.Proj#, auth.sub#,
		sum(cast(auth.Budget$ as float)) CurrentAuthorizedIndirect
		FROM [Brownfield].[LZ_JMAUTHDTLF] Auth
		group by auth.proj#, auth.sub#)
		--select * from currID
	,Total
		AS (
		SELECT jc5.Proj#, jc5.sub#, o.OriginalAuthorizedTotal, CT.CurrentAuthorizedTotal, OID.OriginalAuthorizedIndirect, CID.CurrentAuthorizedIndirect,
		SUM(cast(o.OriginalAuthorizedTotal AS FLOAT)) - SUM(CAST(oid.OriginalAuthorizedIndirect AS FLOAT)) AS OriginalAuthorizedDirect,
		SUM(cast(CT.CurrentAuthorizedTotal AS FLOAT)) - SUM(CAST(CID.CurrentAuthorizedIndirect AS FLOAT)) AS CurrentAuthorizedDirect
		from [Brownfield].[LZ_JMJC5FLDSF] JC5
		left join orig o ON jc5.proj# = o.proj# and jc5.sub# = o.sub#
		left join currtotal ct ON jc5.proj# = CT.proj# and jc5.sub# = CT.sub#
		left join origid oid ON jc5.proj# = oid.proj# and jc5.sub# = oid.sub#
		left join currID cid on jc5.proj# = cid.proj# and jc5.sub# = cid.sub#
		group by jc5.proj#, jc5.sub#, o.OriginalAuthorizedTotal, CT.CurrentAuthorizedTotal, OID.OriginalAuthorizedIndirect, CID.CurrentAuthorizedIndirect
		)
	,bf AS (
	    SELECT [PROJECT], Subproj, sum(cast(Hours as float)) as CATSHours
	    FROM [Brownfield].[LZ_BKSTIME00F]
	    group by Project, Subproj
	)
	,FFH AS (
	    SELECT ProjectNumber,SubprojectNumber, GrossAddsDirect, GrossAddsIndirect, GrossAddsDirect+GrossAddsIndirect grossaddstotal
	    FROM history.ForecastExport
	    WHERE ProductionDate = @YrPrevious and
	    JustificationCode = 5
	)
	,MS AS (
	SELECT projectnumber, subprojectnumber, sum(JanuaryDirect) JanuaryDirect, sum(JanuaryIndirect) JanuaryIndirect, sum(FebruaryDirect) FebruaryDirect, sum(FebruaryIndirect) FebruaryIndirect, 
	sum(MarchDirect) MarchDirect, sum(MarchIndirect) MarchIndirect, sum(AprilDirect) AprilDirect, sum(AprilIndirect) AprilIndirect, sum(MayDirect) MayDirect, sum(MayIndirect) MayIndirect, sum(JuneDirect) JuneDirect, sum(JuneIndirect) JuneIndirect, sum(JulyDirect) JulyDirect, sum(JulyIndirect) JulyIndirect, sum(AugustDirect) AugustDirect, sum(AugustIndirect) AugustIndirect, sum(SeptemberDirect) SeptemberDirect, sum(SeptemberIndirect) SeptemberIndirect, sum(OctoberDirect) OctoberDirect, sum(OctoberIndirect) OctoberIndirect, sum(NovemberDirect) NovemberDirect, sum(NovemberIndirect) NovemberIndirect, sum(DecemberDirect) DecemberDirect, sum(DecemberIndirect) DecemberIndirect
	FROM forecast.ForecastExport
	group by projectnumber, subprojectnumber
	)

	,brownfield as (
	SELECT fff.[ProjectNumber]
	    ,fff.[SubprojectNumber]
	    ,concat(fff.ProjectNumber,fff.SubprojectNumber) as ProjectSubNumber
		,fff.[ClassOfPlant]
	    ,fff.[LinkCode]
	    ,fff.[JustificationCode]
	    ,fff.[FunctionalGroup]
	    ,fff.[ProjectDescription] CurrentProjectDescription
	    ,fff.[ProjectStatusCode] 
	    ,fff.[ApprovalCode] 
	    ,fff.[Company]
		,IIF((ex.exchangename is null or ex.exchangename = '') and ex.[state] = 'FL', 'FL data backbone/fl Miami', ex.exchangename) as ExchangeName
		,fff.[OperatingArea]
		,fff.[State]
		,r.[Region]
	    ,fff.[Engineer]
	    ,fff.[ProjectOwner]
		,IIF(FFf.[ApprovalDate] = 0, NULL, CONVERT(Date, IIF(LEN(FFf.[ApprovalDate]) = 6, SUBSTRING(LTRIM(STR(FFf.[ApprovalDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[ApprovalDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FFf.[ApprovalDate])), 1, 2), SUBSTRING(LTRIM(STR(FFf.[ApprovalDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[ApprovalDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[ApprovalDate])), 2, 2)), 0)) AS [ApprovalDate]
		,IIF(FFf.[EstimatedStartDate] = 0, NULL, CONVERT(Date, IIF(LEN(FFf.[EstimatedStartDate]) = 6, SUBSTRING(LTRIM(STR(FFf.[EstimatedStartDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[EstimatedStartDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FFf.[EstimatedStartDate])), 1, 2), SUBSTRING(LTRIM(STR(FFf.[EstimatedStartDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[EstimatedStartDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[EstimatedStartDate])), 2, 2)), 0)) AS [EstimatedStartDate]
			,IIF(FFf.[EstimatedCompleteDate] = 0, NULL, CONVERT(Date, IIF(LEN(FFf.[EstimatedCompleteDate]) = 6, SUBSTRING(LTRIM(STR(FFf.[EstimatedCompleteDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[EstimatedCompleteDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FFf.[EstimatedCompleteDate])), 1, 2), SUBSTRING(LTRIM(STR(FFf.[EstimatedCompleteDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[EstimatedCompleteDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[EstimatedCompleteDate])), 2, 2)), 0)) AS [EstimatedCompleteDate]
			,IIF(FFf.[ActualStartDate] = 0, NULL, CONVERT(Date, IIF(LEN(FFf.[ActualStartDate]) = 6, SUBSTRING(LTRIM(STR(FFf.[ActualStartDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[ActualStartDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FFf.[ActualStartDate])), 1, 2), SUBSTRING(LTRIM(STR(FFf.[ActualStartDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[ActualStartDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[ActualStartDate])), 2, 2)), 0)) AS [ActualStartDate]
			,IIF(FFf.[ReadyForServiceDate] = 0, NULL, CONVERT(Date, IIF(LEN(FFf.[ReadyForServiceDate]) = 6, SUBSTRING(LTRIM(STR(FFf.[ReadyForServiceDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[ReadyForServiceDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FFf.[ReadyForServiceDate])), 1, 2), SUBSTRING(LTRIM(STR(FFf.[ReadyForServiceDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[ReadyForServiceDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[ReadyForServiceDate])), 2, 2)), 0)) AS [ReadyForServiceDate]
			,IIF(FFf.[TentativeCloseDate] = 0, NULL, CONVERT(Date, IIF(LEN(FFf.[TentativeCloseDate]) = 6, SUBSTRING(LTRIM(STR(FFf.[TentativeCloseDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[TentativeCloseDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FFf.[TentativeCloseDate])), 1, 2), SUBSTRING(LTRIM(STR(FFf.[TentativeCloseDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[TentativeCloseDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[TentativeCloseDate])), 2, 2)), 0)) AS [TentativeCloseDate]
			,IIF(FFf.[CloseDate] = 0, NULL, CONVERT(Date, IIF(LEN(FFf.[CloseDate]) = 6, SUBSTRING(LTRIM(STR(FFf.[CloseDate])), 3, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[CloseDate])), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(FFf.[CloseDate])), 1, 2), SUBSTRING(LTRIM(STR(FFf.[CloseDate])), 4, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[CloseDate])), 6, 2) + '/' + SUBSTRING(LTRIM(STR(FFf.[CloseDate])), 2, 2)), 0)) AS [CloseDate]
	    ,f.[BudgetLineNumber]
	    ,f.[BudgetLineName]
		,m.Percent_Materials_Used PercentMaterialsUsed
		,e.EMC
		,brc.Vendor
	    ,t.OriginalAuthorizedDirect
	    ,t.OriginalAuthorizedIndirect
	    ,t.OriginalAuthorizedTotal
	    ,t.CurrentAuthorizedDirect
	    ,t.CurrentAuthorizedIndirect
	    ,t.CurrentAuthorizedTotal
		,f.[PriorYearsSpendDirect]
	    ,f.[PriorYearsSpendIndirect]
	    ,f.[PriorYearsSpendTotal]
		,ms.JanuaryDirect
		,ms.JanuaryIndirect
		,ms.FebruaryDirect
		,ms.FebruaryIndirect
		,ms.MarchDirect
		,ms.MarchIndirect
		,ms.AprilDirect
		,ms.AprilIndirect
		,ms.MayDirect
		,ms.MayIndirect
		,ms.JuneDirect
		,ms.JuneIndirect
		,ms.JulyDirect
		,ms.JulyIndirect
		,ms.AugustDirect
		,ms.AugustIndirect
		,ms.SeptemberDirect
		,ms.SeptemberIndirect
		,ms.OctoberDirect
		,ms.OctoberIndirect
		,ms.NovemberDirect
		,ms.NovemberIndirect
		,ms.DecemberDirect
		,ms.DecemberIndirect
		,case when f.GrossAddsDirect is null then 0 else f.grossaddsdirect end CurrentYearDirect
	    ,case when f.GrossAddsIndirect is null then 0 else f.grossaddsindirect end CurrentYearIndirect
	    ,case when f.GrossAddsTotal is null then 0 else f.grossaddstotal end CurrentYearTotal
		,case when f.GrossAddsDirect is null then 0 else f.grossaddsdirect end + case when f.PriorYearsSpendDirect is null then 0 else h.grossaddsdirect end TotalDirect
	    ,case when f.GrossAddsIndirect is null then 0 else f.GrossAddsIndirect end + case when f.PriorYearsSpendIndirect is null then 0 else h.grossaddsindirect end TotalIndirect
	    ,case when f.GrossAddsTotal is null then 0 else f.grossaddstotal end + case when f.PriorYearsSpendTotal is null then 0 else h.grossaddstotal end TotalGrossAdds
	    ,f.FutureYearsSpendInfinium
	    ,f.FutureYearsSpend	
	    ,b.CATSHours
	FROM [dbo].[FFFIELDS] fff
	LEFT JOIN FFH h ON fff.ProjectNumber = h.projectnumber and fff.SubprojectNumber = h.SubprojectNumber
	LEFT JOIN ms ms on fff.ProjectNumber = ms.ProjectNumber and fff.SubprojectNumber = ms.SubprojectNumber
	LEFT JOIN [forecast].[ForecastExport] f on fff.ProjectNumber = f.projectnumber and fff.SubprojectNumber = f.SubprojectNumber
	LEFT JOIN [LZ].[MaterialsUsed] m on fff.projectnumber = m.project
	LEFT JOIN bf b on fff.projectnumber = b.PROJECT and fff.SubprojectNumber = b.SUBPROJ
	LEFT JOIN Total t on fff.projectnumber = t.Proj# and fff.SubprojectNumber = t.Sub#
	LEFT JOIN EMC e on fff.projectnumber = e.Project and fff.SubprojectNumber = e.sub
	LEFT JOIN [forecast].[Exchange] ex on fff.Exchangenumber = ex.ExchangeNumber
	LEFT JOIN BulkReelContractor brc ON fff.ProjectNumber = brc.Project
	LEFT JOIN [Brownfield].[Regions] r ON fff.[State] = r.[State]
	WHERE fff.ProjectStatusCode != 'CX' and fff.justificationcode = 5
	)

	Insert into Brownfield.MasterGoldenReport
	Select *
	from Brownfield

	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_LZ_Writer_Master_Golden G
	ON B.EVENTID = G.LATESTID
	DROP TABLE IF EXISTS #Temp_Writer_Master_Golden

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH