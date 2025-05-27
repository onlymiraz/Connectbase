﻿CREATE PROCEDURE [dbo].[FlushContentCache]
    @Path as nvarchar(425)
AS
    SET DEADLOCK_PRIORITY LOW
    SET NOCOUNT ON
    DECLARE @CatalogItemID AS UNIQUEIDENTIFIER

    SELECT @CatalogItemID=ItemID FROM [dbo].[Catalog] WHERE [Path]=@Path

    DELETE
    FROM
       [PowerBIReportServerTempDB].dbo.[ContentCache]
    WHERE
       CatalogItemID = @CatalogItemID

    SELECT @@ROWCOUNT
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FlushContentCache] TO [RSExecRole]
    AS [dbo];

