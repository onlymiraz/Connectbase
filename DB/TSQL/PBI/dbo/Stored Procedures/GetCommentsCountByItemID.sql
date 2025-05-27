CREATE PROCEDURE [dbo].[GetCommentsCountByItemID]
@ItemID uniqueidentifier
AS
BEGIN
    SELECT count(*)
    FROM [Comments] as C
    WHERE C.[ItemID] = @ItemID
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetCommentsCountByItemID] TO [RSExecRole]
    AS [dbo];

