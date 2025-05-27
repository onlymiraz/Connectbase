﻿-- delete all snapshots for all reports that inherit system History policy
CREATE PROCEDURE [dbo].[DeleteHistoriesWithNoPolicy]
AS
SET NOCOUNT OFF
DELETE
FROM History
WHERE HistoryID in
   (SELECT HistoryID
    FROM History JOIN Catalog on ItemID = ReportID
    WHERE SnapshotLimit is null
   )
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[DeleteHistoriesWithNoPolicy] TO [RSExecRole]
    AS [dbo];

