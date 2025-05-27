CREATE procedure [webapp].[usp_GetBudgetCategoryList]
as
begin try
	select ID, BudgetCategory from forecast.BudgetCategory
end try
begin catch
	exec usp_error_handler
	return 55555
end catch