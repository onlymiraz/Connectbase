--- Use SOURCE database
USE CapitalManagementStaging


--- EXAMPLE TABLE IN THIS SCRIPT: forecast.FinanceCategory ("+ @[User::TableName_str] +" in string expression for SSIS package)

--- Be sure to remove all of the comments from this script in the SSIS expression

-------------------------------------


EXEC('TRUNCATE TABLE CapitalManagementDevelopment.forecast.FinanceCategory') AT [DBFarm205]

DECLARE @PK_Condition AS int -- will be used to check if a table has a primary key or not
DECLARE @ID_Condition AS int -- will be used to check if a table has an identity (auto-generated) or read-only column
DECLARE @PK_Table_Columns AS NVARCHAR(MAX) -- comma-separated list of a specified table's column names (meant for primary key tables)
DECLARE @Main_Insert_Query AS NVARCHAR(MAX) -- copying data from source to destination DB is done with INSERT INTO / SELECT statement
DECLARE @Main_Insert_Query_PK1 AS NVARCHAR(MAX) -- for inserting into tables with identity columns (pt 1. copying source table to destination temp table)
DECLARE @Main_Insert_Query_PK2 AS NVARCHAR(MAX) -- for inserting into tables with identity columns (pt 2. copying destination temp table to destination actual table)


--- Filters by table name and will return a count greater than 0 if the table has a primary key (will return 0 otherwise)
	-- will be used for both source & destination tables
SET @PK_Condition = (
	SELECT COUNT(*) 
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
	WHERE [CONSTRAINT_TYPE] = 'PRIMARY KEY' AND TABLE_NAME = SUBSTRING('forecast.FinanceCategory', CHARINDEX('.','forecast.FinanceCategory')+1, 20000)
)


--- Filters by table name and will return a count greater than 0 if the table has an identity (auto-generated) or read-only column
	-- will be used for both source & destination tables
SET @ID_Condition = (
		SELECT COUNT(*)
		FROM
			sys.schemas AS SCH
			INNER JOIN sys.tables AS TAB ON SCH.schema_id = TAB.schema_id
			INNER JOIN sys.columns AS COL ON TAB.object_id = COL.object_id
			INNER JOIN sys.identity_columns AS IDCOL on COL.object_id = IDCOL.object_id AND COL.column_id = IDCOL.column_id
		WHERE TAB.name = SUBSTRING('forecast.FinanceCategory', CHARINDEX('.','forecast.FinanceCategory')+1, 20000)
	)



--- Regarding SUBSTRING() function:
	-- raw query looks something like this: ", [FirstName], [LastName], [UserID]", so below substring function starts at index 3 (the first left bracket)
	-- table names are stored as SCHEMA.NAME format, so the below substring function will retrieve only the table name after the period character (.) using CHARINDEX()
	-- ending index of 200000 is an random large number to account for a very long list of column names
--- Regarding REPLACE() function:
	-- The variable is stored as a string with single quotes, so that REPLACE() function gets rid of the single quotes
	-- NOTE: single quote is escaped with another single quote (e.g. ('[SINGLE QUOTE]') -->('''(escaped)')
	-- Removing single quotes allows for this variable to be used in dynamic SQL query below (@Main_Insert_Query)
SET @PK_Table_Columns = (REPLACE( (SELECT SUBSTRING(
			(
				SELECT ', ' + QUOTENAME(COLUMN_NAME)
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = SUBSTRING('forecast.FinanceCategory', CHARINDEX('.','forecast.FinanceCategory')+1, 20000) AND TABLE_SCHEMA = SUBSTRING('forecast.FinanceCategory', 0, CHARINDEX('.','forecast.FinanceCategory'))
				ORDER BY ORDINAL_POSITION
				FOR XML path('')
			),
        3, 200000)), '''', '')) 

--- Dynamic SQL queries that will be concatenated with column names retrieved in @PK_Table_Columns variable
--- NOTE: An asterisk is NOT used in this query because inserting into primary key tables requires you to explictly list all of the columns, otherwise query will throw an error
--- FROM statement needs to specify SOURCE server

	-- If source table does NOT have any primary keys/identity columns, then perform a direct insert from source to actual destination table:
SET @Main_Insert_Query = N'

	INSERT INTO [DBFarm205].CapitalManagementDevelopment.forecast.FinanceCategory ('+ @PK_Table_Columns +') 
			SELECT ' + @PK_Table_Columns + ' FROM CAPINFWWWPV01.CapitalManagementStaging.forecast.FinanceCategory
'

/**** The below dynamic queries are if source table DOES have primary keys/identity columns ****/


	-- PART 1: Using temp table created by the stored procedure toward the bottom in the IF condition, insert data from source table to destination TEMP table 
SET @Main_Insert_Query_PK1 = N'

	INSERT INTO [DBFarm205].CapitalManagementDevelopment.dbo.TempDestinationTable ('+ @PK_Table_Columns +') 
			SELECT ' + @PK_Table_Columns + ' FROM CAPINFWWWPV01.CapitalManagementStaging.forecast.FinanceCategory

'
	-- PART 2: Insert data from destination TEMP table to destination ACTUAL table
	-- NOTE: Some of the tables may have primary keys/identity columns on the source table, but will not have any on the destination table
		-- So checks to see if the specified DESTINATION table has an identity column ONLY (not primary key), then sets IDENTITY_INSERT constraint based on condition
		-- If source table has any primary keys but no identity columns, it will execute ELSE statement below
		-- THEN, copies insert/select from temp destination table to actual destination table
SET @Main_Insert_Query_PK2 = N'

	IF(' + CAST(@ID_Condition AS nvarchar) + ' > 0 OR)
		BEGIN
			SET IDENTITY_INSERT CapitalManagementDevelopment.forecast.FinanceCategory ON

			INSERT INTO CapitalManagementDevelopment.forecast.FinanceCategory ('+ @PK_Table_Columns +') 
					SELECT ' + @PK_Table_Columns + ' FROM CapitalManagementDevelopment.dbo.TempDestinationTable

			SET IDENTITY_INSERT CapitalManagementDevelopment.forecast.FinanceCategory OFF
		END
	
	ELSE
		BEGIN
			INSERT INTO CapitalManagementDevelopment.forecast.FinanceCategory ('+ @PK_Table_Columns +') 
					SELECT ' + @PK_Table_Columns + ' FROM CapitalManagementDevelopment.dbo.TempDestinationTable
		END
	DROP TABLE CapitalManagementDevelopment.dbo.TempDestinationTable
'





-------------------------------------


--- Executes stored procedure that will copy the actual destination table & create a new temp table in the destination database (removing the identity/PK constraints)
/***STORED PROCEDURE:


	PROCEDURE [dbo].[createtemptable] 
	-- Add the parameters for the stored procedure here
	@tablename nvarchar(max)
	AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
		SET NOCOUNT ON;

		
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
		

***/




--- If there are source primary keys/identity columns:
IF(@ID_Condition > 0 OR @PK_Condition > 0)
	BEGIN
		EXECUTE [DBFarm205].CapitalManagementDevelopment.dbo.createtemptable 'forecast.FinanceCategory'
        
		EXEC(@Main_Insert_Query_PK1)
		EXEC(@Main_Insert_Query_PK2) AT [DBFarm205]
	END

--- If NO source primary keys/identity columns:
ELSE
	BEGIN
		EXEC(@Main_Insert_Query)
	END




--SELECT * FROM forecast.FinanceCategory
---CONFIRMING INSERTS
--select * from CAPINFWWWPV01.CapitalManagementStaging.forecast.FinanceCategory
--select * from [DBFarm205].CapitalManagementDevelopment.forecast.FinanceCategory
--TRUNCATE TABLE [DBFarm205].CapitalManagementDevelopment.forecast.FinanceCategory