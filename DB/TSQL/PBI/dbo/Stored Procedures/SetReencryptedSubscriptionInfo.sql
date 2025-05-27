﻿CREATE PROCEDURE [dbo].[SetReencryptedSubscriptionInfo]
@SubscriptionID as uniqueidentifier,
@ExtensionSettings as ntext = NULL,
@Version as int
AS

UPDATE [dbo].[Subscriptions]
SET [ExtensionSettings] = @ExtensionSettings,
    [Version] = @Version
WHERE [SubscriptionID] = @SubscriptionID
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SetReencryptedSubscriptionInfo] TO [RSExecRole]
    AS [dbo];

