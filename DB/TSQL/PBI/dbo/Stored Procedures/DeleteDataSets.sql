CREATE PROCEDURE [dbo].[DeleteDataSets]
@ItemID [uniqueidentifier]
AS
DELETE
FROM [DataSets]
WHERE [ItemID] = @ItemID
DELETE
FROM [PowerBIReportServerTempDB].dbo.TempDataSets
WHERE [ItemID] = @ItemID
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[DeleteDataSets] TO [RSExecRole]
    AS [dbo];

