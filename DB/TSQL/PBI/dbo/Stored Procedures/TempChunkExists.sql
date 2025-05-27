﻿CREATE PROC [dbo].[TempChunkExists]
    @ChunkId uniqueidentifier
AS
BEGIN
    SELECT COUNT(1) FROM [PowerBIReportServerTempDB].dbo.SegmentedChunk
    WHERE ChunkId = @ChunkId
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[TempChunkExists] TO [RSExecRole]
    AS [dbo];

