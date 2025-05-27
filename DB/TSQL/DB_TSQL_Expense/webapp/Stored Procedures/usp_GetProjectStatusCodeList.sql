CREATE procedure [webapp].[usp_GetProjectStatusCodeList]
as
begin try
	select ProjectStatusCode
	from forecast.ProjectStatusCode
end try
begin catch
	exec usp_error_handler
	return 55555
end catch