--- Use SOURCE database
USE CapitalManagementStaging


--- For [dbo].[2020 Justification Code Document-Final 3.30.20] table ONLY

--- Added as a separate step in ETL SQL Server job

-------------------------------------


EXEC('TRUNCATE TABLE CapitalManagementDevelopment.[dbo].[2020 Justification Code Document-Final 3.30.20]') AT [DBFarm205]

DECLARE @PK_Table_Columns AS NVARCHAR(MAX) -- comma-separated list of a specified table's column names (meant for primary key tables)
DECLARE @Main_Insert_Query AS NVARCHAR(MAX) -- copying data from source to destination DB is done with INSERT INTO / SELECT statement



SET @PK_Table_Columns = (REPLACE( (SELECT SUBSTRING(
			(
				SELECT ', ' + QUOTENAME(COLUMN_NAME)
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = '2020 Justification Code Document-Final 3.30.20' AND TABLE_SCHEMA = 'dbo'
				ORDER BY ORDINAL_POSITION
				FOR XML path('')
			),
        3, 200000)), '''', '')) 

--- Dynamic SQL queries that will be concatenated with column names retrieved in @PK_Table_Columns variable
--- NOTE: An asterisk is NOT used in this query because inserting into primary key tables requires you to explictly list all of the columns, otherwise query will throw an error
--- FROM statement needs to specify SOURCE server

SET @Main_Insert_Query = N'

	INSERT INTO [DBFarm205].CapitalManagementDevelopment.[dbo].[2020 Justification Code Document-Final 3.30.20]('+ @PK_Table_Columns +') 
			SELECT ' + @PK_Table_Columns + ' FROM CAPINFWWWPV01.CapitalManagementStaging.[dbo].[2020 Justification Code Document-Final 3.30.20]
'


EXEC(@Main_Insert_Query)



