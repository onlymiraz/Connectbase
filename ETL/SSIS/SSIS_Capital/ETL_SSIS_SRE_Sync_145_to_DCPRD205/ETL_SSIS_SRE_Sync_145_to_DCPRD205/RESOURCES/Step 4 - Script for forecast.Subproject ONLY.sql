--- Use SOURCE database
USE CapitalManagementStaging


--- Create temp table in destination database
EXECUTE [DBFarm205].CapitalManagementDevelopment.dbo.createtemptable 'forecast.Subproject'

--- Truncate temp table, since we can't truncate actual destination table
EXEC('TRUNCATE TABLE CapitalManagementDevelopment.dbo.TempDestinationTable') AT [DBFarm205]


--- Retrieve all of the new subproject numbers from source table and insert them into the temp destination table
INSERT INTO [DBFarm205].CapitalManagementDevelopment.dbo.TempDestinationTable
SELECT * FROM CAPINFWWWPV01.CapitalManagementStaging.forecast.Subproject AS source_tab
WHERE NOT EXISTS (
	SELECT 1 FROM [DBFarm205].CapitalManagementDevelopment.forecast.Subproject
	WHERE CAST(source_tab.ProjectNumber AS nvarchar) + ', ' + CAST(source_tab.SubprojectNumber AS nvarchar) 
		= CAST(ProjectNumber AS nvarchar) + ', ' + CAST(SubprojectNumber AS nvarchar)
)


--- Append new projects data from temp destination table to actual destination table
--- Temporarily disable/enable tgr_SubprojectInsert trigger function since we are just copying data
--- THEN, drop temp destination table when done
EXEC(N'
		ALTER TABLE CapitalManagementDevelopment.forecast.Subproject DISABLE TRIGGER tgr_SubprojectInsert
		

		INSERT INTO CapitalManagementDevelopment.forecast.Subproject
			SELECT * FROM CapitalManagementDevelopment.dbo.TempDestinationTable

		ALTER TABLE CapitalManagementDevelopment.forecast.Subproject ENABLE TRIGGER tgr_SubprojectInsert
		

		DROP TABLE CapitalManagementDevelopment.dbo.TempDestinationTable 

') AT [DBFarm205]
