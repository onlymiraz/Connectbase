CREATE PROCEDURE [dbo].[LockPersistedStream]
@SessionID varchar(32),
@Index int
AS

SELECT [Index] FROM [PowerBIReportServerTempDB].dbo.PersistedStream WITH (XLOCK) WHERE SessionID = @SessionID AND [Index] = @Index
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LockPersistedStream] TO [RSExecRole]
    AS [dbo];

