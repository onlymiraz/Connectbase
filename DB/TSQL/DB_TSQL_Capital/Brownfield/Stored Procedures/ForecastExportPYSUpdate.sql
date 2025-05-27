CREATE PROCEDURE [Brownfield].[ForecastExportPYSUpdate]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS #Temp_ForecastExportPYSUpdate
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])

	VALUES
	('[Brownfield].[ForecastExportPYSUpdate]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'Create ForecastExportPYSUpdate')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_ForecastExportPYSUpdate
	FROM [LOG].[Tracker]
	
	SET NOCOUNT ON;

	truncate table [Brownfield].[ForecastExportPriorYearsSpendUpdate]

	DECLARE @YrPrevious DATE
	DECLARE @YrCurrent DATE
	SET @YrPrevious = '2023-01-09'
	SET @YrCurrent = '2023-01-09'

	Insert Into [Brownfield].[ForecastExportPriorYearsSpendUpdate]
	select x.projectnumber, x.subprojectnumber, x.justificationcode, x.grossaddstotal, x.PriorYearsSpendTotal,x.PriorYearsSpendDirectFinal,x.prioryearsspendindirectfinal,x.prioryearsspendtotalfinal, x.endinggrossaddstotal, x.productiondate
	from
	(select ProjectNumber, SubprojectNumber, GrossAddsTotal, PriorYearsSpendTotal, justificationcode,
	case when GrossAddsTotal !=0 and  productiondate <= @yrcurrent then GrossAddsTotal+PriorYearsSpendTotal else PriorYearsSpendTotal end as PriorYearsSpendTotalFinal, productiondate,
	case when GrossAddsTotal !=0 and productiondate <= @YrCurrent then '0' else GrossAddsTotal end as EndingGrossAddsTotal,
	case when GrossAddsTotal !=0 and  productiondate <= @yrcurrent then GrossAddsDirect+PriorYearsSpendDirect else PriorYearsSpendDirect end as PriorYearsSpendDirectFinal,
	case when GrossAddsTotal !=0 and productiondate <= @YrCurrent then '0' else PriorYearsSpendDirect end as PriorYearsSpendDirect,
	case when GrossAddsTotal !=0 and  productiondate <= @yrcurrent then GrossAddsIndirect+PriorYearsSpendIndirect else PriorYearsSpendIndirect end as PriorYearsSpendIndirectFinal,
	case when GrossAddsTotal !=0 and productiondate <= @YrCurrent then '0' else GrossAddsindirect end as PriorYearsSpendIndirect,
	ROW_Number()over(partition by projectnumber, subprojectnumber order by productiondate desc) as max_date from history.ForecastExport) x
	where x.JustificationCode = 5 and x.max_date = 1

UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_ForecastExportPYSUpdate P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_ForecastExportPYSUpdate

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH