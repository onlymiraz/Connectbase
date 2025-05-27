-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [forecast].[usp_ImportProjects]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ImportProjects
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_ImportProjects]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_ImportProjects
FROM [LOG].[Tracker]


		MERGE forecast.Project AS P
		USING (SELECT DISTINCT ProjectNumber, ProjectDescription, ClassOfPlant, LinkCode, JustificationCode, FunctionalGroup, Billable, ApprovalCode,
					ProjectType, Company, ExchangeName, OperatingArea, [State], Engineer, ProjectOwner FROM dbo.ForecastImport) AS F
		ON P.ProjectNumber = F.ProjectNumber
		WHEN MATCHED THEN
			UPDATE
			SET P.[ProjectDescription] = F.[ProjectDescription],
				P.[ClassOfPlant] = F.[ClassOfPlant],
				P.[LinkCode] = F.[LinkCode],
				P.[JustificationCode] = F.[JustificationCode],
				P.[FunctionalGroup] = F.[FunctionalGroup],
				P.[Billable] = F.[Billable],
				P.[ApprovalCode] = F.[ApprovalCode],
				P.[ProjectType] = F.[ProjectType],
				P.[Company] = F.[Company],
				P.[ExchangeName] = F.[ExchangeName],
				P.[OperatingArea] = F.[OperatingArea],
				P.[State] = F.[State],
				P.[Engineer] = F.[Engineer],
				P.ProjectOwner = F.ProjectOwner
		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, ProjectDescription, ClassOfPlant, LinkCode, JustificationCode, FunctionalGroup, Billable, ApprovalCode,
						ProjectType, Company, ExchangeName, OperatingArea, [State], Engineer, ProjectOwner)
			VALUES (F.ProjectNumber, F.ProjectDescription, F.ClassOfPlant, F.LinkCode, F.JustificationCode, F.FunctionalGroup, F.Billable, F.ApprovalCode,
						F.ProjectType, F.Company, F.ExchangeName, F.OperatingArea, F.[State], F.Engineer, F.ProjectOwner);
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_ImportProjects P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ImportProjects
	
	
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH