CREATE PROCEDURE [dbo].[GetCatalogExtendedContentLastUpdate]
    @CatalogItemID UNIQUEIDENTIFIER,
    @ContentType VARCHAR(50)
AS
BEGIN
    SELECT
        ModifiedDate
    FROM
        [CatalogItemExtendedContent] WITH (NOWAIT) -- DevNote: Modified Date is included in the index, we don't expect this to be locked
    WHERE
        [ItemID] = @CatalogItemID AND ContentType = @ContentType
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetCatalogExtendedContentLastUpdate] TO [RSExecRole]
    AS [dbo];

