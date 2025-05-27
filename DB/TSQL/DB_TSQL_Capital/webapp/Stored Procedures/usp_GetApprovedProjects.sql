-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [webapp].[usp_GetApprovedProjects]
AS
	SET NOCOUNT ON
BEGIN TRY
	SELECT * FROM dbo.APPROVED
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(2048) = error_message()
	RAISERROR (@msg, 16, 1)
	RETURN 55555
END CATCH
