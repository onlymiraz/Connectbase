-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_FixImports]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	DELETE FROM ForecastImport
	WHERE ProjectNumber IS NULL

	DELETE FROM FFFIELDS
	WHERE ProjectNumber = '1170942'
END TRY
BEGIN CATCH
	EXEC usp_error_handler
	RETURN 55555
END CATCH