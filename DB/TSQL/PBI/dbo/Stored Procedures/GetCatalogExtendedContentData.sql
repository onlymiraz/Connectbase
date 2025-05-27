CREATE PROCEDURE [dbo].[GetCatalogExtendedContentData]
    @CatalogItemID UNIQUEIDENTIFIER,
    @ContentType VARCHAR(50)
AS
BEGIN
    SELECT
        DATALENGTH([Content]) AS ContentLength,
        [Content]
    FROM
        [CatalogItemExtendedContent] WITH (NOWAIT) -- DevNote: Using NOWAIT here because for large models the row might be locked for long durations. Fail fast and let the client retry.
    WHERE
        [ItemID] = @CatalogItemID AND ContentType = @ContentType

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetCatalogExtendedContentData] TO [RSExecRole]
    AS [dbo];

