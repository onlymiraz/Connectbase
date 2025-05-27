--- Use SOURCE database
USE CapitalManagementStaging


--- Create temp table in destination database
EXECUTE [DBFarm205].CapitalManagementDevelopment.dbo.createtemptable 'forecast.Project'

--- Truncate temp table, since we can't truncate actual destination table
EXEC('TRUNCATE TABLE CapitalManagementDevelopment.dbo.TempDestinationTable') AT [DBFarm205]


--- Retrieve all of the new project numbers from source table and insert them into the temp destination table
INSERT INTO [DBFarm205].CapitalManagementDevelopment.dbo.TempDestinationTable
SELECT * FROM CAPINFWWWPV01.CapitalManagementStaging.forecast.Project AS source_tab
WHERE NOT EXISTS (
	SELECT 1 FROM [DBFarm205].CapitalManagementDevelopment.forecast.Project
	WHERE source_tab.ProjectNumber = ProjectNumber
)


--- Append new projects data from temp destination table to actual destination table
--- THEN, drop temp destination table when done
EXEC(N'

		INSERT INTO CapitalManagementDevelopment.forecast.Project
			SELECT * FROM CapitalManagementDevelopment.dbo.TempDestinationTable

		DROP TABLE CapitalManagementDevelopment.dbo.TempDestinationTable 

') AT [DBFarm205]
