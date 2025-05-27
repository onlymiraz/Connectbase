CREATE PROCEDURE [dbo].[UpdateCatalogExtendedContentModifiedDate]
    @CatalogItemID UNIQUEIDENTIFIER,
    @ContentType VARCHAR(50),
    @ModifiedDate DATETIME = NULL
AS
BEGIN
    IF @ModifiedDate IS NULL SET @ModifiedDate = GETDATE() -- DevNote: For backward compatibility

    UPDATE
        [dbo].[CatalogItemExtendedContent]
    SET
        ModifiedDate = @ModifiedDate
    WHERE
        ItemID = @CatalogItemID AND
        ContentType = @ContentType AND
        -- DevNote: This stored procedure gets called in a Transaction. To handle race condition,
        -- update the modified date if it's older than the provided one
        ModifiedDate < @ModifiedDate
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UpdateCatalogExtendedContentModifiedDate] TO [RSExecRole]
    AS [dbo];

