CREATE PROCEDURE [dbo].[GetDataModelDataSourcesByItemIdAndModel]
    @ItemId uniqueidentifier,
    @ModelConnectionName varchar(260)
AS
    SELECT
        D.DSID,
        D.ItemId,
        D.DSType,
        D.DSKind,
        D.AuthType,
        D.ConnectionString,
        D.Username,
        D.Password,
        CU.UserName AS CreatedBy,
        D.CreatedDate,
        MU.UserName AS ModifiedBy,
        D.ModifiedDate,
        D.DataSourceID,
        D.ModelConnectionName
    FROM
        [DataModelDataSource] as D
        INNER JOIN [dbo].[Users] AS CU ON D.CreatedByID = CU.UserID
        INNER JOIN [dbo].[Users] AS MU ON D.ModifiedByID = MU.UserID
    WHERE
        D.[ItemId] = @ItemId
        AND D.[ModelConnectionName] = @ModelConnectionName
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetDataModelDataSourcesByItemIdAndModel] TO [RSExecRole]
    AS [dbo];

