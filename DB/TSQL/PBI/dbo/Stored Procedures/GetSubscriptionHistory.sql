CREATE PROCEDURE [dbo].[GetSubscriptionHistory]
	@SubscriptionID UNIQUEIDENTIFIER
AS
BEGIN

	SELECT
		[SubscriptionID],
		[SubscriptionHistoryID],
		[Type],
		[StartTime],
		[EndTime],
		[Status],
		[Message],
		[Details]
	FROM
		[SubscriptionHistory]
	WHERE
		[SubscriptionID] = @SubscriptionID
	ORDER BY [StartTime] DESC

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetSubscriptionHistory] TO [RSExecRole]
    AS [dbo];

