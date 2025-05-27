--- Use SOURCE database
USE CapitalManagementProduction


--- Create temp table in destination database
EXECUTE [DBFarm304].CapitalManagementProduction.dbo.createtemptable 'forecast.Subproject'

--- Truncate temp table, since we can't truncate actual destination table
EXEC('TRUNCATE TABLE CapitalManagementProduction.dbo.TempDestinationTable') AT [DBFarm304]


--- Retrieve all of the new subproject numbers from source table and insert them into the temp destination table
INSERT INTO [DBFarm304].CapitalManagementProduction.dbo.TempDestinationTable
SELECT * FROM CAPINFWWAPV01.CapitalManagementProduction.forecast.Subproject AS source_tab
WHERE NOT EXISTS (
	SELECT 1 FROM [DBFarm304].CapitalManagementProduction.forecast.Subproject
	WHERE CAST(source_tab.ProjectNumber AS nvarchar) + ', ' + CAST(source_tab.SubprojectNumber AS nvarchar) 
		= CAST(ProjectNumber AS nvarchar) + ', ' + CAST(SubprojectNumber AS nvarchar)
)


--- Append new projects data from temp destination table to actual destination table
--- Temporarily disable/enable tgr_SubprojectInsert trigger function since we are just copying data
--- THEN, drop temp destination table when done
EXEC(N'
		ALTER TABLE CapitalManagementProduction.forecast.Subproject DISABLE TRIGGER tgr_SubprojectInsert
		

		INSERT INTO CapitalManagementProduction.forecast.Subproject
			SELECT * FROM CapitalManagementProduction.dbo.TempDestinationTable

		ALTER TABLE CapitalManagementProduction.forecast.Subproject ENABLE TRIGGER tgr_SubprojectInsert
		

		DROP TABLE CapitalManagementProduction.dbo.TempDestinationTable 

') AT [DBFarm304]
