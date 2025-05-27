
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [webapp].[usp_GetSubprojectStatusList]
AS
	SET NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
		SELECT SubprojectStatus
		FROM forecast.SubprojectStatus
		WHERE ID < 100
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	EXEC usp_error_handler
	RETURN 55555
END CATCH