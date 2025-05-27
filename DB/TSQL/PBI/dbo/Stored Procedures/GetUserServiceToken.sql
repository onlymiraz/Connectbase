﻿CREATE PROCEDURE [dbo].[GetUserServiceToken]
@UserSid as varbinary(85) = NULL,
@UserName as nvarchar(260) = NULL,
@AuthType int
AS
BEGIN

DECLARE @UserID uniqueidentifier
EXEC GetUserID @UserSid, @UserName, @AuthType, @UserID OUTPUT

if (@UserID is not null)
    BEGIN
        SELECT ServiceToken FROM Users WHERE UserId = @UserID
    END
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetUserServiceToken] TO [RSExecRole]
    AS [dbo];

