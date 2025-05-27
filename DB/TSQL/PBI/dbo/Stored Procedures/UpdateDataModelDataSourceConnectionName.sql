CREATE PROCEDURE [dbo].[UpdateDataModelDataSourceConnectionName]
    @DataSourceID UNIQUEIDENTIFIER,
    @ModelConnectionName VARCHAR(260),
    @ConnectionString varbinary(max) = null
AS
BEGIN
UPDATE [dbo].[DataModelDataSource]
SET
    [ModelConnectionName] = @ModelConnectionName,
    [ConnectionString] = @ConnectionString
WHERE [DataSourceID] = @DataSourceID
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UpdateDataModelDataSourceConnectionName] TO [RSExecRole]
    AS [dbo];

