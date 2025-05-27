﻿CREATE PROCEDURE [dbo].[UpdateSnapshotReferences]
    @OldSnapshotId UNIQUEIDENTIFIER,
    @NewSnapshotId UNIQUEIDENTIFIER,
    @IsPermanentSnapshot BIT,
    @TransientRefCountModifier INT,
    @UpdatedReferences INT OUTPUT
AS
BEGIN
    SET @UpdatedReferences = 0

    IF(@IsPermanentSnapshot = 1)
    BEGIN
        -- Update Snapshot Executions
        UPDATE [dbo].[Catalog]
        SET [SnapshotDataID] = @NewSnapshotId
        WHERE [SnapshotDataID] = @OldSnapshotId

        SELECT @UpdatedReferences = @UpdatedReferences + @@ROWCOUNT

        -- Update History
        UPDATE [dbo].[History]
        SET [SnapshotDataID] = @NewSnapshotId
        WHERE [SnapshotDataID] = @OldSnapshotId

        SELECT @UpdatedReferences = @UpdatedReferences + @@ROWCOUNT

        UPDATE [dbo].[SnapshotData]
        SET [PermanentRefcount] = [PermanentRefcount] - @UpdatedReferences,
            [TransientRefcount] = [TransientRefcount] + @TransientRefCountModifier
        WHERE [SnapshotDataID] = @OldSnapshotId

        UPDATE [dbo].[SnapshotData]
        SET [PermanentRefcount] = [PermanentRefcount] + @UpdatedReferences
        WHERE [SnapshotDataID] = @NewSnapshotId
    END
    ELSE
    BEGIN
        -- Update Execution Cache
        UPDATE [PowerBIReportServerTempDB].dbo.[ExecutionCache]
        SET [SnapshotDataID] = @NewSnapshotId
        WHERE [SnapshotDataID] = @OldSnapshotId

        SELECT @UpdatedReferences = @UpdatedReferences + @@ROWCOUNT

        UPDATE [PowerBIReportServerTempDB].dbo.[SnapshotData]
        SET [PermanentRefcount] = [PermanentRefcount] - @UpdatedReferences,
            [TransientRefcount] = [TransientRefcount] + @TransientRefCountModifier
        WHERE [SnapshotDataID] = @OldSnapshotId

        UPDATE [PowerBIReportServerTempDB].dbo.[SnapshotData]
        SET [PermanentRefcount] = [PermanentRefcount] + @UpdatedReferences
        WHERE [SnapshotDataID] = @NewSnapshotId
    END
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UpdateSnapshotReferences] TO [RSExecRole]
    AS [dbo];

