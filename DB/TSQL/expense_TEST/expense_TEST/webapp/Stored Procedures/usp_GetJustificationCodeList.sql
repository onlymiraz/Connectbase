create procedure webapp.[usp_GetJustificationCodeList]
as
	set xact_abort, nocount on
begin try 
	select JustificationCode, JustificationTitle, FunctionalGroup, BudgetCategoryID, SubBudgetCategoryID
	from forecast.JustificationCode
end try
begin catch
	exec usp_error_handler
	return 55555
end catch