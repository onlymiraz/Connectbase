﻿CREATE PROCEDURE [dbo].[UpdateSubscriptionHistoryEntry]
	@SubscriptionHistoryID BIGINT,
	@EndTime DATETIME,
	@Status TINYINT,
	@Message NVARCHAR(1500),
	@Details NVARCHAR(4000)
AS
BEGIN

	UPDATE [dbo].[SubscriptionHistory]
	   SET [EndTime] = @EndTime
		  ,[Status] = @Status
		  ,[Message] = @Message
		  ,[Details] = @Details
	 WHERE [SubscriptionHistoryID] = @SubscriptionHistoryID

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UpdateSubscriptionHistoryEntry] TO [RSExecRole]
    AS [dbo];

