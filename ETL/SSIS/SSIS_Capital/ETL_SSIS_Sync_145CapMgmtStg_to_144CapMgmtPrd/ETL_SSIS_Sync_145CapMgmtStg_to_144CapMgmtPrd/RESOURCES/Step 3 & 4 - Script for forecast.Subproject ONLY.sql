--- Use SOURCE database
USE CapitalManagementStaging


/**********

	NOTE: Only if you keep receiving an error regarding the TempDestinationTable not existing, 
	create a separate step (PT1) in the SQL Server job for just the two EXECUTE/EXEC queries below;
	Create this step before the 2nd part of this script (PT2; the insertions)

***********/
--- Create temp table in destination database
EXECUTE [CAPINFWWAPV01].CapitalManagementProduction.dbo.createtemptable 'forecast.Subproject'

--- Truncate temp table, since we can't truncate actual destination table
EXEC('TRUNCATE TABLE CapitalManagementProduction.dbo.TempDestinationTable') AT [CAPINFWWAPV01]


--- Retrieve all of the new subproject numbers from source table and insert them into the temp destination table
INSERT INTO [CAPINFWWAPV01].CapitalManagementProduction.dbo.TempDestinationTable
SELECT * FROM CAPINFWWWPV01.CapitalManagementStaging.forecast.Subproject AS source_tab
WHERE NOT EXISTS (
	SELECT 1 FROM [CAPINFWWAPV01].CapitalManagementProduction.forecast.Subproject
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

') AT [CAPINFWWAPV01]
