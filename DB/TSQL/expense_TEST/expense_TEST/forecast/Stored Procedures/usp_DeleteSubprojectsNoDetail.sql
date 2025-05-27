create procedure forecast.usp_DeleteSubprojectsNoDetail
as
	set xact_abort, nocount on
begin try
begin transaction
	DELETE FROM forecast.Subproject
	WHERE (ProjectNumber * 10 + SubprojectNumber) IN (
		SELECT (ProjectNumber * 10 + SubprojectNumber)
		FROM (
			SELECT ProjectNumber, SubprojectNumber FROM forecast.Subproject S
			EXCEPT
			SELECT ProjectNumber, SubprojectNumber FROM dbo.AUTHDETAIL) A
		)
commit transaction
end try
begin catch
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
end catch