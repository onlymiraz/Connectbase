﻿CREATE PROCEDURE [dbo].[WriteFirstPortionPersistedStream]
@SessionID varchar(32),
@Index int,
@Name nvarchar(260) = NULL,
@MimeType nvarchar(260) = NULL,
@Extension nvarchar(260) = NULL,
@Encoding nvarchar(260) = NULL,
@Content image
AS

UPDATE [PowerBIReportServerTempDB].dbo.PersistedStream set Content = @Content, [Name] = @Name, MimeType = @MimeType, Extension = @Extension WHERE SessionID = @SessionID AND [Index] = @Index

SELECT TEXTPTR(Content) FROM [PowerBIReportServerTempDB].dbo.PersistedStream WHERE SessionID = @SessionID AND [Index] = @Index
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WriteFirstPortionPersistedStream] TO [RSExecRole]
    AS [dbo];

