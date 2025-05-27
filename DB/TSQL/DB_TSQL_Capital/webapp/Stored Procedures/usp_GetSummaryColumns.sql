create procedure webapp.usp_GetSummaryColumns
as
	set xact_abort, nocount on
begin try
	select ColumnName, Alias, GroupID
	from forecast.SummaryColumn
end try
begin catch
	EXEC usp_error_handler
	return 55555
end catch