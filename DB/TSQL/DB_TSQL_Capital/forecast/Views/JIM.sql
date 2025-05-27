CREATE VIEW [forecast].[JIM] (Proj, AuthorizedTotal, RemainderToSpend, SpentTotal)
AS SELECT 
	ProjectNumber, 
	sum(AuthorizedTotal),
	sum(RemainderToSpend),
	sum(GrossAddsTotal+PriorYearsSpendTotal)
FROM [forecast].[ForecastExport]
group by ProjectNumber