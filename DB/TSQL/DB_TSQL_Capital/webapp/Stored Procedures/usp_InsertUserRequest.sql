CREATE procedure [webapp].[usp_InsertUserRequest]
	@username varchar(10),
	@first_name varchar(25),
	@last_name varchar(25),
	@email varchar(50),
	@comment varchar(1000)
as
	set xact_abort, nocount on
begin try
	begin transaction
		insert into webapp.[UserRequest] (Username, FirstName, LastName, Email, Comment, DateRequested)
		values (@username, @first_name, @last_name, @email, @comment, GETUTCDATE())
	commit transaction
end try
begin catch
	if @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
end catch