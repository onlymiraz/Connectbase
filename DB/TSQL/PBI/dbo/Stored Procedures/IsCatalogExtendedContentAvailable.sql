﻿CREATE PROCEDURE [dbo].[IsCatalogExtendedContentAvailable]
    @CatalogItemID UNIQUEIDENTIFIER,
    @ContentType VARCHAR(50)
AS
DECLARE @isAvailable BIT = 0
IF EXISTS (SELECT * FROM [dbo].[CatalogItemExtendedContent] WHERE [ItemID] = @CatalogItemID AND ContentType = @ContentType)
BEGIN
    SET @isAvailable = 1
END

SELECT @isAvailable AS isAvailable
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IsCatalogExtendedContentAvailable] TO [RSExecRole]
    AS [dbo];

