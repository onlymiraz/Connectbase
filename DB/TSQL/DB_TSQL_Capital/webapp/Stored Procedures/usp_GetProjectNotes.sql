
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [webapp].[usp_GetProjectNotes]
	@project_number int,
	@subproject_number int
AS
	SET NOCOUNT ON
BEGIN TRY
	SELECT N.ID, N.SubprojectNumber, NT.[Type], N.[Text], N.CreatedBy, N.CreatedDate, N.ModifiedBy, N.ModifiedDate
	FROM forecast.Note N LEFT JOIN forecast.NoteType NT ON N.TypeID = NT.ID
	WHERE ProjectNumber = @project_number
	ORDER BY N.CreatedDate DESC
END TRY
BEGIN CATCH
	EXEC usp_error_handler
	RETURN 55555
END CATCH
