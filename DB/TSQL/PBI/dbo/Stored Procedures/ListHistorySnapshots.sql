﻿-- list all historical snapshots for a specific report with full fields
CREATE PROCEDURE [dbo].[ListHistorySnapshots]
@ReportID uniqueidentifier
AS
SELECT
   S.HistoryID,
   S.ReportID,
   S.SnapshotDataID,
   S.SnapshotDate,
   ISNULL((SELECT SUM(DATALENGTH( CD.Content ) ) FROM ChunkData AS CD WHERE CD.SnapshotDataID = S.SnapshotDataID ), CAST (0 as bigint)) + 
   ISNULL(
	(
	 SELECT SUM(DATALENGTH( SEG.Content) ) 	
	 FROM Segment SEG WITH(NOLOCK)
	 JOIN ChunkSegmentMapping CSM WITH(NOLOCK) ON (CSM.SegmentId = SEG.SegmentId)
	 JOIN SegmentedChunk C WITH(NOLOCK) ON (C.ChunkId = CSM.ChunkId AND C.SnapshotDataId = S.SnapshotDataId)
	), CAST (0 as bigint)) AS Size	
FROM
   History AS S -- skipping intermediate table SnapshotData
WHERE
   S.ReportID = @ReportID
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ListHistorySnapshots] TO [RSExecRole]
    AS [dbo];

