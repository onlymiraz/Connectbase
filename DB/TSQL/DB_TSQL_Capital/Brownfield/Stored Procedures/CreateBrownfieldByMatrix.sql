CREATE PROCEDURE [Brownfield].[CreateBrownfieldByMatrix]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_CreateBrownfieldByMatrix
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])

	VALUES
	('[Brownfield].[BrownfieldByMatrix]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Create Brownfield By Matrix')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_CreateBrownfieldByMatrix
	FROM [LOG].[Tracker]
	
	SET NOCOUNT ON;

	truncate table [Brownfield].[BrownfieldByMatrix]

;WITH ga
AS (
  SELECT
    GAPRJ#, gaprjs, GAMTRX, SUM(CAST(GARPT$ AS money)) spend
  FROM [history].[GALisa]
  WHERE GAACTY = 2021
and GAPRJS in ('1','4')
  GROUP BY GAPRJ#, gaprjs, GAMTRX
)
,u AS (
  SELECT
    g.*
  FROM ga g
)
,projbymatrix as (
SELECT *
FROM (
  SELECT GAPRJ#, gaprjs, GAMTRX, spend
  FROM u
) AS SourceTable
PIVOT (
  sum(spend)
  FOR GAMTRX IN ([111],[276],[277],[278],[279],[280],[281],[322],[329],[342],[343],[344],[345],[361],[362],[363],[364],[365],[367],[401],[405],[411],[412],[414],[415],[420],[421],[422],[423],[424],[425],[427],[428],[429],[434],[437],[440],[441],[445],[456],[457],[461],[471],[472],[473],[475],[477],[486],[487],[501],[502],[503],[504],[505],[544],[902],[939],[990],[991],[992],[993],[994],[995],[996],[997],[998],[999])
) AS PivotTable
)
,proj AS (
select GAPRJ# Project
, gaprjs Sub
,case when [280] > 0 or [343]>0 or [344]> 0  then 'E' else '' end
+case when [502] > 0 then 'M' else '' end
+case when [345] > 0 then 'C' else '' end EMC
, [111],[276],[277],[278],[279],[280],[281],[322],[329],[342],[343],[344],[345],[361],[362],[363],[364],[365],[367],[401],[405],[411],[412],[414],[415],[420],[421],[422],[423],[424],[425],[427],[428],[429],[434],[437],[440],[441],[445],[456],[457],[461],[471],[472],[473],[475],[477],[486],[487],[501],[502],[503],[504],[505],[544],[902],[939],[990],[991],[992],[993],[994],[995],[996],[997],[998],[999]
from projbymatrix
)
Insert into Brownfield.BrownfieldByMatrix
select p.*, f.ClassOfPlant, f.LinkCode, f.JustificationCode, f.ProjectStatusCode, f.ProjectDescription
from proj p
left join dbo.FFFIELDS f ON f.ProjectNumber = p.Project and f.SubprojectNumber = p.Sub
where f.JustificationCode = 5

UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_CreateBrownfieldByMatrix M
	ON B.EVENTID = M.LATESTID
	DROP TABLE IF EXISTS #Temp_CreateBrownfieldByMatrix

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH