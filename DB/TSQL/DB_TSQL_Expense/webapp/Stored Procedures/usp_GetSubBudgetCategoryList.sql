CREATE procedure [webapp].[usp_GetSubBudgetCategoryList]
as
begin try
	select ID, MainID, SubBudgetCategory, Separator, Overwrite from forecast.SubBudgetCategory
end try
begin catch
	exec usp_error_handler
	return 55555
end catch