CREATE PROCEDURE [pushpull].[parser_ListAvailProjects]
AS
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION

    DROP TABLE IF EXISTS #Temp_LZ_ListAvailProjects;
	INSERT INTO [LOG].[Tracker]
		([EVENTNAME]
		,[EVENTSTART]
		,[EVENTTYPE]
		,[EVENTDESCRIPTION])
	VALUES
	('[PushPull].[LZ_ListAvailProjects]'
		,CAST(GETDATE() AS DATETIME)
		,'STORE PROC'
		,'parse LZ_ListAvailProjects')

	SELECT MAX(EVENTID) AS LATESTID INTO #Temp_LZ_ListAvailProjects
	FROM [LOG].[Tracker]

  TRUNCATE TABLE [PushPull].[LZ_ListAvailProjects];

INSERT INTO [PushPull].[LZ_ListAvailProjects] ([ProjectNumber])
SELECT [Infinium_ProjectNumber]
FROM [LZ].[infinium_project_budget];
UPDATE p
SET p.[Year] = a.[Budget_Year]
 
from [LZ].[infinium_project_budget] a
 
JOIN [PushPull].[LZ_ListAvailProjects] p
 
ON a.Infinium_ProjectNumber = p.ProjectNumber
 
UPDATE p
 
SET p.[State] = a.[project_State]
 
from [LZ].[infinium_project_budget] a
 
JOIN [PushPull].[LZ_ListAvailProjects] p
 
ON a.Infinium_ProjectNumber = p.ProjectNumber
 
UPDATE p
 
SET p.[JustificationCode] = a.[JustificationCode]
 
from [LZ].[infinium_project_budget] a
 
JOIN [PushPull].[LZ_ListAvailProjects] p
 
ON a.Infinium_ProjectNumber = p.ProjectNumber
 
UPDATE p
 
SET p.[ProjectType] = a.[ClassOfPlant]
 
from [LZ].[infinium_project_budget] a
 
JOIN [PushPull].[LZ_ListAvailProjects] p
 
ON a.Infinium_ProjectNumber = p.ProjectNumber
 
 UPDATE p

SET p.[Wirecenter] = a.[GAEXCH]

from [history].[GALisa] a

JOIN [PushPull].[LZ_ListAvailProjects] p

ON a.GAPRJ# = p.ProjectNumber

  	UPDATE B
	SET B.EVENTEND=CAST(GETDATE() AS DATETIME)
	FROM LOG.Tracker B
	INNER JOIN #Temp_LZ_ListAvailProjects P
	ON B.EVENTID = P.LATESTID
	DROP TABLE IF EXISTS #Temp_LZ_ListAvailProjects  

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@trancount > 0 ROLLBACK TRANSACTION
    EXEC usp_error_handler
    RETURN 55555
END CATCH;