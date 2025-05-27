﻿CREATE PROCEDURE [dbo].[AddDataModelRole]
    @ItemID uniqueidentifier,
    @ModelRoleID uniqueidentifier,
    @ModelRoleName NVARCHAR(255)
AS
BEGIN
    INSERT INTO 
        [dbo].[DataModelRole]([ItemID], [ModelRoleID], [ModelRoleName])
    VALUES
        (@ItemID, @ModelRoleID, @ModelRoleName)
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AddDataModelRole] TO [RSExecRole]
    AS [dbo];

