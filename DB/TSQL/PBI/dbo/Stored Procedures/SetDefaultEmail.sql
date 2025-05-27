﻿CREATE PROCEDURE [dbo].[SetDefaultEmail]
    @UserID uniqueidentifier,
    @DefaultEmailAddress nvarchar(256)
AS
BEGIN
    IF EXISTS (SELECT * FROM UserContactInfo WHERE UserID = @UserID) BEGIN
        UPDATE UserContactInfo SET
        DefaultEmailAddress = @DefaultEmailAddress
        WHERE UserID=@UserID
    END ELSE BEGIN
        INSERT
        INTO [UserContactInfo] (UserID, DefaultEmailAddress)
        VALUES (@UserID, @DefaultEmailAddress)
    END
END