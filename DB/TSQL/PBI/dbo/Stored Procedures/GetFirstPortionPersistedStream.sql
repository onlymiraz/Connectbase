﻿CREATE PROCEDURE [dbo].[GetFirstPortionPersistedStream]
@SessionID varchar(32)
AS

SELECT
    TOP 1
    TEXTPTR(P.Content),
    DATALENGTH(P.Content),
    P.[Index],
    P.[Name],
    P.MimeType,
    P.Extension,
    P.Encoding,
    P.Error
FROM
    [PowerBIReportServerTempDB].dbo.PersistedStream P WITH (XLOCK)
WHERE
    P.SessionID = @SessionID
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetFirstPortionPersistedStream] TO [RSExecRole]
    AS [dbo];

