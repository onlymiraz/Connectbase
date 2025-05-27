--- Use SOURCE database
USE CapitalManagementProduction


--- For [dbo].[2020 Justification Code Document-Final 3.30.20] table ONLY

--- Added as a separate step in ETL SQL Server job

-------------------------------------

---- TRUNCATE destination table (performing this action one table at a time, instead of all tables at once)
EXEC('TRUNCATE TABLE CapitalManagementProduction.[dbo].[2020 Justification Code Document-Final 3.30.20]') AT [DBFarm304]


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



SET @Main_Insert_Query = N'

	INSERT INTO [DBFarm304].CapitalManagementProduction.[dbo].[2020 Justification Code Document-Final 3.30.20] ('+ @PK_Table_Columns +') 
			SELECT ' + @PK_Table_Columns + ' FROM CAPINFWWAPV01.CapitalManagementProduction.[dbo].[2020 Justification Code Document-Final 3.30.20]
'

EXEC(@Main_Insert_Query)
	



