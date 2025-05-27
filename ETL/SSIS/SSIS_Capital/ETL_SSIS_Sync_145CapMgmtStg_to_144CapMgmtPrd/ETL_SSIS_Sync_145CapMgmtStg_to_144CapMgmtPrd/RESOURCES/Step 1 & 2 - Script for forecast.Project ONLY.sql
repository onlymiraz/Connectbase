--- Use SOURCE database
USE CapitalManagementStaging

/**********

	NOTE: Only if you keep receiving an error regarding the TempDestinationTable not existing, 
	create a separate step (PT1) in the SQL Server job for just the two EXECUTE/EXEC queries below;
	Create this step before the 2nd part of this script (PT2; the insertions)

***********/
--- Create temp table in destination database
EXECUTE [CAPINFWWAPV01].CapitalManagementProduction.dbo.createtemptable 'forecast.Project'

--- Truncate temp table, since we can't truncate actual destination table
EXEC('TRUNCATE TABLE CapitalManagementProduction.dbo.TempDestinationTable') AT [CAPINFWWAPV01]


--- Retrieve all of the new project numbers from source table and insert them into the temp destination table
INSERT INTO [CAPINFWWAPV01].CapitalManagementProduction.dbo.TempDestinationTable
SELECT * FROM CAPINFWWWPV01.CapitalManagementStaging.forecast.Project AS source_tab
WHERE NOT EXISTS (
	SELECT 1 FROM [CAPINFWWAPV01].CapitalManagementProduction.forecast.Project
	WHERE source_tab.ProjectNumber = ProjectNumber
)


--- Append new projects data from temp destination table to actual destination table
--- THEN, drop temp destination table when done
EXEC(N'

		INSERT INTO CapitalManagementProduction.forecast.Project
			SELECT * FROM CapitalManagementProduction.dbo.TempDestinationTable

		DROP TABLE CapitalManagementProduction.dbo.TempDestinationTable 

') AT [CAPINFWWAPV01]
