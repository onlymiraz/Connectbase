CREATE VIEW [Brownfield].[BrownfieldMatrixEMC]
	AS WITH ga
AS (
  SELECT
    GAPRJ#, gaprjs, GAMTRX, SUM(CAST(GARPT$ AS money)) spend
  FROM [history].[GALisa]
  WHERE CAST(GAJTCD AS INT) = 5
  --and GAPRJ#='2492378'
  and GAPRJS in ('1','4')
    AND IIF(GATDTE = 0, NULL, CONVERT(Date, IIF(LEN(GATDTE) = 6, SUBSTRING(LTRIM(STR(GATDTE)), 3, 2) + '/' + SUBSTRING(LTRIM(STR(GATDTE)), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(GATDTE)), 1, 2), SUBSTRING(LTRIM(STR(GATDTE)), 4, 2) + '/' + SUBSTRING(LTRIM(STR(GATDTE)), 6, 2) + '/' + SUBSTRING(LTRIM(STR(GATDTE)), 2, 2)), 0)) >= '2022-01-01'
  GROUP BY GAPRJ#, gaprjs, GAMTRX, IIF(GATDTE = 0, NULL, CONVERT(Date, IIF(LEN(GATDTE) = 6, SUBSTRING(LTRIM(STR(GATDTE)), 3, 2) + '/' + SUBSTRING(LTRIM(STR(GATDTE)), 5, 2) + '/21' + SUBSTRING(LTRIM(STR(GATDTE)), 1, 2), SUBSTRING(LTRIM(STR(GATDTE)), 4, 2) + '/' + SUBSTRING(LTRIM(STR(GATDTE)), 6, 2) + '/' + SUBSTRING(LTRIM(STR(GATDTE)), 2, 2)), 0))
)
/*
  SELECT
    sum(g.spend)
  FROM ga g
  LEFT JOIN [dbo].[FFFIELDS] f ON g.GAPRJ# = f.ProjectNumber AND g.GAPRJS = f.SubprojectNumber
  WHERE f.ProjectStatusCode NOT IN ('CL', 'CX')
*/

,u AS (
  SELECT
    g.*
  FROM ga g
  LEFT JOIN [dbo].[FFFIELDS] f ON g.GAPRJ# = f.ProjectNumber AND g.GAPRJS = f.SubprojectNumber
  WHERE f.ProjectStatusCode NOT IN ('CL', 'CX')
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
select GAPRJ# Project
, gaprjs Sub
,case when [280] > 0 or [343]>0 or [344]> 0  then 'E' else '' end
+case when [502] > 0 then 'M' else '' end
+case when [345] > 0 then 'C' else '' end EMC
, [111],[276],[277],[278],[279],[280],[281],[322],[329],[342],[343],[344],[345],[361],[362],[363],[364],[365],[367],[401],[405],[411],[412],[414],[415],[420],[421],[422],[423],[424],[425],[427],[428],[429],[434],[437],[440],[441],[445],[456],[457],[461],[471],[472],[473],[475],[477],[486],[487],[501],[502],[503],[504],[505],[544],[902],[939],[990],[991],[992],[993],[994],[995],[996],[997],[998],[999]
from projbymatrix