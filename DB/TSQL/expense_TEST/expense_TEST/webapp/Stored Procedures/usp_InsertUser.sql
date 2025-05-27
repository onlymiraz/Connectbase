CREATE procedure [webapp].[usp_InsertUser]
	@username varchar(10),
	@first_name varchar(25),
	@last_name varchar(25),
	@email varchar(50),
	@is_admin bit
as
	set xact_abort, nocount on
begin try
	begin transaction
		insert into webapp.[User] (Username, FirstName, LastName, Email, IsAdmin, LastLoggedIn)
		values (@username, @first_name, @last_name, @email, ISNULL(@is_admin, 0), GETUTCDATE())
	commit transaction
end try
begin catch
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
end catch