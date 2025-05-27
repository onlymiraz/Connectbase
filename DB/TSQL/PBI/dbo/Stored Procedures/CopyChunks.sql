CREATE PROCEDURE [dbo].[CopyChunks]
    @OldSnapshotId UNIQUEIDENTIFIER,
    @NewSnapshotId UNIQUEIDENTIFIER,
    @IsPermanentSnapshot BIT
AS
BEGIN
    IF(@IsPermanentSnapshot = 1) BEGIN
        -- copy non-segmented chunks
        INSERT [dbo].[ChunkData] (
            ChunkId,
            SnapshotDataId,
            ChunkFlags,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            Content
            )
        SELECT
            NEWID(),
            @NewSnapshotId,
            [c].[ChunkFlags],
            [c].[ChunkName],
            [c].[ChunkType],
            [c].[Version],
            [c].[MimeType],
            [c].[Content]
        FROM [dbo].[ChunkData] [c] WHERE [c].[SnapshotDataId] = @OldSnapshotId

        -- copy segmented chunks... real easy just add the mapping
        INSERT [dbo].[SegmentedChunk](
            ChunkId,
            SnapshotDataId,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            ChunkFlags
            )
        SELECT
            ChunkId,
            @NewSnapshotId,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            ChunkFlags
        FROM [dbo].[SegmentedChunk] WITH (INDEX (UNIQ_SnapshotChunkMapping))
        WHERE [SnapshotDataId] = @OldSnapshotId
    END
    ELSE BEGIN
        -- copy non-segmented chunks
        INSERT [PowerBIReportServerTempDB].dbo.[ChunkData] (
            ChunkId,
            SnapshotDataId,
            ChunkFlags,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            Content
            )
        SELECT
            NEWID(),
            @NewSnapshotId,
            [c].[ChunkFlags],
            [c].[ChunkName],
            [c].[ChunkType],
            [c].[Version],
            [c].[MimeType],
            [c].[Content]
        FROM [PowerBIReportServerTempDB].dbo.[ChunkData] [c] WHERE [c].[SnapshotDataId] = @OldSnapshotId

        -- copy segmented chunks... real easy just add the mapping
        INSERT [PowerBIReportServerTempDB].[dbo].[SegmentedChunk](
            ChunkId,
            SnapshotDataId,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            ChunkFlags,
            Machine
            )
        SELECT
            ChunkId,
            @NewSnapshotId,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            ChunkFlags,
            Machine
        FROM [PowerBIReportServerTempDB].dbo.[SegmentedChunk] WITH (INDEX (UNIQ_SnapshotChunkMapping))
        WHERE [SnapshotDataId] = @OldSnapshotId
    END
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CopyChunks] TO [RSExecRole]
    AS [dbo];

