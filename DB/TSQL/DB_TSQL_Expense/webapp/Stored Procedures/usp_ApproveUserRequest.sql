CREATE procedure [webapp].[usp_ApproveUserRequest]
	@request_id int,
	@is_admin bit
as
	set xact_abort, nocount on
begin try
	begin transaction
		insert into webapp.[User] (Username, FirstName, LastName, Email, IsAdmin)
		select Username, FirstName, LastName, Email, @is_admin
		from webapp.UserRequest
		where ID = @request_id

		delete from webapp.UserRequest
		where ID = @request_id
	commit transaction
end try
begin catch
	if @@trancount > 0 rollback transaction
	exec usp_error_handler
	return 55555
end catch