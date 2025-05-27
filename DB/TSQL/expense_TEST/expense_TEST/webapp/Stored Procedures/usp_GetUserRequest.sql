create procedure webapp.usp_GetUserRequest
	@username varchar(10)
as
	set xact_abort, nocount on
begin try
		select Username, FirstName, LastName, Email, Comment, DateRequested
		from webapp.UserRequest
		where Username = @username
end try
begin catch
	exec usp_error_handler
	return 55555
end catch