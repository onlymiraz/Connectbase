﻿CREATE PROCEDURE [dbo].[DeleteOneChunk]
@SnapshotID uniqueidentifier,
@IsPermanentSnapshot bit,
@ChunkName nvarchar(260),
@ChunkType int
AS
SET NOCOUNT OFF
-- for segmented chunks we just need to
-- remove the mapping, the cleanup thread
-- will pick up the rest of the pieces
IF @IsPermanentSnapshot != 0 BEGIN

DELETE ChunkData
WHERE
    SnapshotDataID = @SnapshotID AND
    ChunkName = @ChunkName AND
    ChunkType = @ChunkType

DELETE	SegmentedChunk
WHERE
    SnapshotDataId = @SnapshotID AND
    ChunkName = @ChunkName AND
    ChunkType = @ChunkType

END ELSE BEGIN

DELETE [PowerBIReportServerTempDB].dbo.ChunkData
WHERE
    SnapshotDataID = @SnapshotID AND
    ChunkName = @ChunkName AND
    ChunkType = @ChunkType

DELETE	[PowerBIReportServerTempDB].dbo.SegmentedChunk
WHERE
    SnapshotDataId = @SnapshotID AND
    ChunkName = @ChunkName AND
    ChunkType = @ChunkType

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[DeleteOneChunk] TO [RSExecRole]
    AS [dbo];

