use [ExpenseForecastStaging]
DECLARE @today date=GETDATE()
DECLARE @yesterday date=cast(DATEADD(day,-1,GETDATE()) as date)

--Marginal Parser Log_PJ
;with today as (
SELECT [Yr]
      ,[Mo]
      ,[ct_Rows]
      ,[ParserDateTime]
  FROM [LOG].[Parser_GA_PJExpense]
  where cast(ParserDateTime as date)=@today
)
,yesterday as (
SELECT [Yr]
      ,[Mo]
      ,[ct_Rows]
      ,[ParserDateTime]
  FROM [LOG].[Parser_GA_PJExpense]
  where cast(ParserDateTime as date)=@yesterday
)
select t.yr,t.mo,y.ct_Rows RowCountYesterday,t.[ct_Rows] RowCountToday,t.[ct_Rows]-y.ct_Rows Ingested_Today
from today t
left join yesterday y on t.Yr=y.Yr and t.Mo=y.mo
order by t.Yr,t.mo
