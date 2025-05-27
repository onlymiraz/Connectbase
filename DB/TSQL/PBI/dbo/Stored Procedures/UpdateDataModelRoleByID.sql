﻿CREATE PROCEDURE [dbo].[UpdateDataModelRoleByID]
    @DataModelRoleID bigint,
    @ModelRoleName NVARCHAR(255)
AS
BEGIN
    UPDATE 
        [dbo].[DataModelRole]
    SET
        [ModelRoleName] = @ModelRoleName
    WHERE 
        [DataModelRoleID] = @DataModelRoleID
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UpdateDataModelRoleByID] TO [RSExecRole]
    AS [dbo];

