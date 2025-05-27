-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_CreateErrorReport]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM forecast.ErrorReport

	/*
	Error Types

	Data Entry: 
	Data Mismatch: 

	*/

	-- Mismatching justification code between subprojects 1 & 4
	INSERT INTO forecast.ErrorReport (ProjectNumber, ErrorType, ErrorDescription, ColumnName1, ColumnValue1, ColumnName2, ColumnValue2)
	SELECT F.ProjectNumber, 'Data Mismatch', 'Justification code does not match between subprojects 1 and 4', 'Sub 1 Justification Code', F.JustificationCode, 'Sub 4 JustificationCode', FF.JustificationCode
	FROM FFFIELDS AS F INNER JOIN FFFIELDS AS FF ON F.ProjectNumber = FF.ProjectNumber INNER JOIN forecast.Subproject AS S ON F.ProjectNumber = S.ProjectNumber AND F.SubprojectNumber = S.SubprojectNumber
	WHERE F.SubprojectNumber = '1' AND FF.SubprojectNumber = '4' AND F.JustificationCode != FF.JustificationCode

	-- Incorrect project description for blanket budget category or project incorrectly categorized as blanket
	INSERT INTO forecast.ErrorReport (ProjectNumber, SubprojectNumber, ErrorType, ErrorDescription, ColumnName1, ColumnValue1, ColumnName2, ColumnValue2)
	SELECT F.ProjectNumber, F.SubprojectNumber, 'Data Mismatch', 'Project description for blanket budget category does not start with year or project incorrect categorized as blanket', 'Budget Category', P.BudgetCategoryID, 'Project Description', F.ProjectDescription
	FROM FFFIELDS AS F INNER JOIN forecast.Project AS P ON F.ProjectNumber = P.ProjectNumber
	WHERE F.ProjectDescription NOT LIKE '20%' AND P.JustificationCode IN (20, 21, 22, 23, 24, 25, 76)

	-- Mismatching justification code and functional group
	INSERT INTO forecast.ErrorReport (ProjectNumber, SubprojectNumber, ErrorType, ErrorDescription, ColumnName1, ColumnValue1, ColumnName2, ColumnValue2, ColumnName3, ColumnValue3)
	SELECT F.ProjectNumber, F.SubprojectNumber, 'Data Mismatch', 'Mismatching justification code and functional group', 'Justification Code', F.JustificationCode, 'Incorrect Functional Group', F.FunctionalGroup, 'Correct Functional Group', J.FunctionalGroup
	FROM FFFIELDS AS F INNER JOIN forecast.Subproject AS S ON F.ProjectNumber = S.ProjectNumber AND F.SubprojectNumber = S.SubprojectNumber INNER JOIN forecast.JustificationCode AS J ON F.JustificationCode = J.JustificationCode
	WHERE F.FunctionalGroup != J.FunctionalGroup

	-- Incorrect justification code and/or functional group with budget line(s) specified in forecast.BudgetCategoryCorrection table
	INSERT INTO forecast.ErrorReport (ProjectNumber, SubprojectNumber, ErrorType, ErrorDescription, ColumnName1, ColumnValue1, ColumnName2, ColumnValue2, ColumnName3, ColumnValue3)
	SELECT F.ProjectNumber, F.SubprojectNumber, 'Data Mismatch', 'Incorrect justification code and/or functional group with linked budget line', 'JustificationCode', F.JustificationCode, 'FunctionalGroup', F.FunctionalGroup, 'BudgetLineNumber', S.BudgetLineNumber
	FROM FFFIELDS AS F INNER JOIN forecast.Subproject AS S ON F.ProjectNumber = S.ProjectNumber AND F.SubprojectNumber = S.SubprojectNumber INNER JOIN forecast.BudgetCategoryCorrection AS C ON S.BudgetLineNumber = C.BudgetLineNumber
	WHERE C.BudgetLineNumber IS NOT NULL AND (F.JustificationCode != 81 OR F.FunctionalGroup != 'G')

	-- Incorrect justification code with link code(s) specified in forecast.BudgetCategoryCorrection table
	INSERT INTO forecast.ErrorReport (ProjectNumber, SubprojectNumber, ErrorType, ErrorDescription, ColumnName1, ColumnValue1, ColumnName2, ColumnValue2)
	SELECT F.ProjectNumber, F.SubprojectNumber, 'Data Mismatch', 'Incorrect justification code with given link code', 'BudgetCategory', J.BudgetCategory, 'LinkCode', F.LinkCode
	FROM FFFIELDS AS F INNER JOIN forecast.Subproject AS S ON F.ProjectNumber = S.ProjectNumber AND F.SubprojectNumber = S.SubprojectNumber INNER JOIN forecast.JustificationCode AS J ON F.JustificationCode = J.JustificationCode INNER JOIN forecast.BudgetCategoryCorrection AS C ON F.LinkCode = C.LinkCode
	WHERE C.LinkCode IS NOT NULL AND F.JustificationCode != 81

END