CREATE PROCEDURE [PushPull].[Writer_Original_Budget]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_Writer_Original_Budget
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])

	VALUES
	('[PushPull].[Writer_Original_Budget]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Create Original Budget Report')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_Writer_Original_Budget
	FROM [LOG].[Tracker]

	SET NOCOUNT ON;

	truncate table [PushPull].[OriginalBudget]

;with cpl as (
	select distinct ProjectNumber, SubprojectNumber, CloseDate, ga.GAACTY, ga.GAOBUD
	from [dbo].[FFFIELDS] fff
	left join history.galisa ga on fff.projectnumber = ga.gaprj#
	where ProjectStatusCode != 'CX' and (CloseDate = '0' or CloseDate like '%23')
		)
		
	,db as (
select distinct [ProjectMasterNumbr], LineSubProject#, ProjJustificatCode, 
sum(cast(linebudgetamount as float)) OrigBudgDirect
from [PushPull].[LZ_PushPull]
where CostCode != '999' and costcode != '998' and costcode != '996' and costcode != '995' and costcode != '994' and costcode != '993' and costcode != '992' and costcode != '991' and costcode != '990'
group by ProjectMasterNumbr, ProjJustificatCode, LineSubProject#, OrigBudgetAmount
)

	,idb as (
select distinct [ProjectMasterNumbr],LineSubProject#, ProjJustificatCode, sum(cast(linebudgetamount as float)) OrigBudgIndirect
from [PushPull].[LZ_PushPull]
where CostCode = '999' or costcode = '998' or costcode = '996' or costcode = '995' or costcode = '994' or costcode = '993' or costcode = '992' or costcode = '991' or costcode = '990'
group by ProjectMasterNumbr, ProjJustificatCode, LineSubProject#, OrigBudgetAmount
)

	,TrimBudget as (
select distinct cpl.projectnumber, cpl.subprojectnumber, lz.ProjJustificatCode, 
case when cast(db.origbudgdirect as float) is null then 0.00 else db.OrigBudgDirect end as origbudgdirect, 
case when cast(idb.origbudgindirect as float) is null then 0.00 else idb.origbudgindirect end as origbudgindirect,
--case when cast(db.OrigBudgDirect + idb.origbudgindirect as float) is null then 0.00 else cast(db.OrigBudgDirect + idb.origbudgindirect as float) end as OrigBudgTotal, OrigBudgetAmount
lz.OrigBudgetAmount
from [PushPull].[LZ_PushPull] lz

left join cpl on lz.ProjectMasterNumbr = cpl.ProjectNumber and lz.LineSubProject# = cpl.SubprojectNumber
left join db on cpl.ProjectNumber = db.ProjectMasterNumbr and cpl.SubprojectNumber = db.LineSubProject#
left join idb on cpl.ProjectNumber = idb.ProjectMasterNumbr and cpl.SubprojectNumber = idb.LineSubProject#

 where cpl.projectnumber is not null
)
	,budgettotal as (select distinct projectnumber ProjectMasterNumbr, subprojectnumber, ProjJustificatCode, cast(origbudgdirect as money) origbudgdirect, cast(OrigBudgetAmount as money) TotalBudget--, origbudgindirect
	from TrimBudget	
			)
	
	
	Insert into PushPull.OriginalBudget
	
	select * 
	from BudgetTotal
	order by ProjectMasterNumbr asc
	

	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_Writer_Original_Budget G
	ON B.EVENTID = G.LATESTID

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH