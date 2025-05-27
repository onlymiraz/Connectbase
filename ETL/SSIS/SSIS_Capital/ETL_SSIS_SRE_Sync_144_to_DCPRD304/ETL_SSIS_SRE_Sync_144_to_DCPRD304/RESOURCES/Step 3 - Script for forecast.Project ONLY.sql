--- Use SOURCE database
USE CapitalManagementProduction


--- Create temp table in destination database
EXECUTE [DBFarm304].CapitalManagementProduction.dbo.createtemptable 'forecast.Project'

--- Truncate temp table, since we can't truncate actual destination table
EXEC('TRUNCATE TABLE CapitalManagementProduction.dbo.TempDestinationTable') AT [DBFarm304]


--- Retrieve all of the new project numbers from source table and insert them into the temp destination table
INSERT INTO [DBFarm304].CapitalManagementProduction.dbo.TempDestinationTable
SELECT * FROM CAPINFWWAPV01.CapitalManagementProduction.forecast.Project AS source_tab
WHERE NOT EXISTS (
	SELECT 1 FROM [DBFarm304].CapitalManagementProduction.forecast.Project
	WHERE source_tab.ProjectNumber = ProjectNumber
)


--- Append new projects data from temp destination table to actual destination table
--- THEN, drop temp destination table when done
EXEC(N'

		INSERT INTO CapitalManagementProduction.forecast.Project
			SELECT * FROM CapitalManagementProduction.dbo.TempDestinationTable

		DROP TABLE CapitalManagementProduction.dbo.TempDestinationTable 

') AT [DBFarm304]
