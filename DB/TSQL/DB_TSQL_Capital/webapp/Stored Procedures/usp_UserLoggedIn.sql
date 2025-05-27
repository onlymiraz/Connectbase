CREATE procedure [webapp].[usp_UserLoggedIn]
	@user_id varchar(10)
as
	set xact_abort, nocount on
begin try
	begin transaction
		update webapp.[User]
		set LastLoggedIn = GETUTCDATE()
		where UserID = @user_id
	commit transaction
end try
begin catch
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
end catch