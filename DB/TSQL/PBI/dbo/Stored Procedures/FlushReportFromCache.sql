﻿CREATE PROCEDURE [dbo].[FlushReportFromCache]
@Path as nvarchar(425)
AS

SET DEADLOCK_PRIORITY LOW

-- VSTS #139360: SQL Deadlock in GetReportForexecution stored procedure
-- Use temporary table to keep the same order of accessing the ExecutionCache
-- and SnapshotData tables as GetReportForExecution does, that is first
-- delete from the ExecutionCache, then update the SnapshotData
CREATE TABLE #tempSnapshot (SnapshotDataID uniqueidentifier)
INSERT INTO #tempSnapshot SELECT SN.SnapshotDataID
FROM
   [PowerBIReportServerTempDB].dbo.SnapshotData AS SN WITH (UPDLOCK)
   INNER JOIN [PowerBIReportServerTempDB].dbo.ExecutionCache AS EC WITH (UPDLOCK) ON SN.SnapshotDataID = EC.SnapshotDataID
   INNER JOIN Catalog AS C ON EC.ReportID = C.ItemID
WHERE C.Path = @Path

DELETE EC
FROM
   [PowerBIReportServerTempDB].dbo.ExecutionCache AS EC
   INNER JOIN #tempSnapshot ON #tempSnapshot.SnapshotDataID = EC.SnapshotDataID

UPDATE SN
   SET SN.PermanentRefcount = SN.PermanentRefcount - 1
FROM
   [PowerBIReportServerTempDB].dbo.SnapshotData AS SN
   INNER JOIN #tempSnapshot ON #tempSnapshot.SnapshotDataID = SN.SnapshotDataID
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FlushReportFromCache] TO [RSExecRole]
    AS [dbo];

