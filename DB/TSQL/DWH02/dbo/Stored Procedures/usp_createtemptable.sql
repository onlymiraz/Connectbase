-- =============================================
-- Author:		Priscilla Arinze
-- Create date: 
-- Description:	
-- =============================================
create PROCEDURE [dbo].[usp_createtemptable] 
	-- Add the parameters for the stored procedure here
	@tablename nvarchar(max) 
	   
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DROP TABLE IF EXISTS TempDestinationTable

	-- When select/inserting, identity constraints are always there; below query is to get rid of identity constraint from temp table 
	-- EXPLANATION: Because of the 1 = 0 condition, the right side will have no matches and thus prevent duplication of the left side rows, 
	-- and because this is an outer join, the left side rows will not be eliminated either. Finally, because this is a join, the IDENTITY property is eliminated.
	-- See https://dba.stackexchange.com/a/138345

	DECLARE @DynamicSQL nvarchar(max)
	SET @DynamicSQL = 'SELECT with_identity.* INTO TempDestinationTable
	FROM ' + @tablename + ' AS with_identity
	LEFT JOIN ' + @tablename + ' AS without_identity ON 1 = 0'


	EXEC (@DynamicSQL)
END