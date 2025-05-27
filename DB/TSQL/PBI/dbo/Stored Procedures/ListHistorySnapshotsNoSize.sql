-- list all historical snapshots for a specific report without size data
CREATE PROCEDURE [dbo].[ListHistorySnapshotsNoSize]
@ReportID uniqueidentifier
AS
SELECT
   S.HistoryID,
   S.ReportID,
   S.SnapshotDataID,
   S.SnapshotDate,
   CAST (0 as bigint) AS Size
FROM
   History AS S -- skipping intermediate table SnapshotData
WHERE
   S.ReportID = @ReportID
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ListHistorySnapshotsNoSize] TO [RSExecRole]
    AS [dbo];

