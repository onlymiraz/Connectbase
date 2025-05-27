CREATE procedure [forecast].[usp_UpdateVarassetStatus]
as
	set xact_abort, nocount on
begin try
begin transaction
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateVarassetStatus
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateVarassetStatus]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateVarassetStatus
FROM [LOG].[Tracker]




UPDATE [dbo].[Varasset_FPStatus]
SET [OSP Project Status] = [COE Project Status]
WHERE [OSP Project Status] IS NULL
AND [COE Project Status] IS NOT NULL


	UPDATE S
	SET S.VarassetStatus = V.[OSP Project Status],
		S.VarassetStatusModifiedDate = cast(V.[FP Project Status Updated On] as date),
		S.VarassetClosingIssue = LEFT(V.[Closing Issue], 100),
		S.VarassetScheduledFinishDate = cast(V.[Scheduled Finish] as date),
		S.VarassetWorkOrderStatus = left(V.[Varasset Work Order Status], 50)
	FROM forecast.Subproject S INNER JOIN dbo.Varasset_FPStatus V ON S.ProjectNumber = CAST(V.Project AS INT) AND S.SubprojectNumber = CAST(V.Subproject AS SMALLINT)


UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateVarassetStatus P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateVarassetStatus



commit transaction
end try
begin catch
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
end catch