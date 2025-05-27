create procedure webapp.usp_GetSummaryColumnGroups
as
	set xact_abort, nocount on
begin try
	select ID, GroupName, [Order]
	from forecast.SummaryColumnGroup
end try
begin catch
	EXEC usp_error_handler
	return 55555
end catch