DECLARE @YrPrevious DATE
SET @YrPrevious = '2023-01-09'

;WITH FFH AS (
    SELECT [ProjectSubNumber], GrossAddsDirect, GrossAddsIndirect, GrossAddsTotal
    FROM history.ForecastExport
    WHERE ProductionDate = @YrPrevious
)
SELECT f.[ProjectNumber]
    ,f.[SubprojectNumber]
    ,f.[ProjectSubNumber]
    ,f.[BudgetLineNumber]
    ,f.[BudgetLineName]
    ,f.[ClassOfPlant]
    ,f.[LinkCode]
    ,f.[JustificationCode]
    ,f.[FunctionalGroup]
    ,f.[ProjectDescription] CurrentProjectDescription
    ,f.[ProjectStatusCode] CurrentProjectStatus
    ,f.[ApprovalCode] CurrentApprovalCode
    ,f.[Company]
    ,f.[Exchange]
    ,f.[OperatingArea]
    ,f.[State]
    ,f.[Engineer]
    ,f.[ProjectOwner]
    ,f.[ApprovalDate]
    ,f.[EstimatedStartDate]
	,f.[EstimatedCompleteDate]
    ,f.[ActualStartDate]
    ,f.[ReadyForServiceDate]
    ,f.[TentativeCloseDate]
    ,f.[CloseDate]
	,h.GrossAddsDirect PrevYearDirect
	,h.GrossAddsIndirect PrevYearIndirect
	,h.GrossAddsTotal PrevYearTotalGrossAdds
	,f.GrossAddsDirect CurrYearDirect
	,f.GrossAddsIndirect CurrYearIndirect
	,f.GrossAddsTotal CurrYearTotalGrossAdds
    ,f.GrossAddsDirect + h.GrossAddsDirect TotalDirect
    ,f.GrossAddsIndirect + h.GrossAddsIndirect TotalIndirect
    ,f.GrossAddsTotal + h.GrossAddsTotal TotalGrossAdds
	,f.[PriorYearsSpendDirect]
	,f.[PriorYearsSpendIndirect]
	,f.[PriorYearsSpendTotal]
	,f.FutureYearsSpendInfinium
	,f.FutureYearsSpend
FROM [forecast].[ForecastExport] f
LEFT JOIN FFH h ON f.projectsubnumber = h.projectsubnumber
JOIN [CapitalManagementProduction].[FTTH].[FTTH_Materials_Projects] m on f.ProjectNumber = m.PROJ#
where m.[Received QTY] != 0 and m.[Received QTY] is not null
"""

df = pd.read_sql_query(script, cnxn)

writer = pd.ExcelWriter('D:\\DataDump\\LoadLZ\\Master_Golden.xlsx')

df.to_excel(writer, sheet_name='Master_Golden', index=0)
writer.save()

print("Completed Writer")
"""
shutil.copy2('D:\\DataDump\\LoadLZ\\Master_Golden.xlsx', 'E:\\Capital Management Application\\Queries\\Master_Golden.xlsx')
print("Copied the writer")
"""
