﻿CREATE PROCEDURE [dbo].[GetDataModelRoleAssignmentsByItemID]
    @ItemID uniqueidentifier
AS
    SELECT
        UR.[UserID],
        U.[UserName],
        R.[DataModelRoleID],
        R.[ModelRoleID],
        R.[ModelRoleName]
    FROM
        [dbo].[UserDataModelRole] UR
        INNER JOIN [dbo].[DataModelRole] R ON R.[DataModelRoleID] = UR.[DataModelRoleID]
        INNER JOIN [dbo].[Users] U ON U.[UserID] = UR.[UserID]
    WHERE
        [ItemID] = @ItemID
    ORDER BY UR.[UserID]
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetDataModelRoleAssignmentsByItemID] TO [RSExecRole]
    AS [dbo];

