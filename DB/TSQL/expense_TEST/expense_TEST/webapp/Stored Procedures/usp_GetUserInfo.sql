CREATE procedure [webapp].[usp_GetUserInfo]
	@username varchar(10)
as
	set xact_abort, nocount on
begin try
	select UserID, Username, FirstName, LastName, Email, IsAdmin from webapp.[User]
	where Username = @username
end try
begin catch
	EXEC usp_error_handler
	RETURN 55555
end catch