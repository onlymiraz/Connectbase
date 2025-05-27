﻿CREATE PROCEDURE [dbo].[GetAlertSubscriptionID]
@UserID uniqueidentifier,
@ItemID uniqueidentifier,
@AlertType nvarchar(50)
AS
BEGIN
    SELECT
        AlertSubscriptionID
    FROM [AlertSubscribers]
    WHERE
        UserID = @UserID AND
        ItemID = @ItemID AND
        AlertType = @AlertType
END