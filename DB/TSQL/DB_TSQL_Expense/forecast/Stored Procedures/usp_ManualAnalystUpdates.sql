
CREATE PROCEDURE [forecast].[usp_ManualAnalystUpdates]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION

DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ManualAnalystUpdates
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_ManualAnalystUpdates]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')



SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_ManualAnalystUpdates
FROM [LOG].[Tracker]




----------------------------------------------------------------------------------
----Manual analyst updates
--truncate table webapp.MSFormsAnalystUpdates
--Landing zone
truncate table webapp.ManualAnalystUpdates
BULK INSERT webapp.ManualAnalystUpdates
FROM '\\nspinfwcipp01\Capital_Management\Capital Management Application\Queries\Analyst Notes.txt'
with (firstrow = 2)

--Trim landing zone
update [webapp].[ManualAnalystUpdates]
set [Spend Not Needed] = 0 where [Spend Not Needed] is null

update [webapp].[ManualAnalystUpdates]
set [Future Years Spending] = 0 where [Future Years Spending] is null

----Add previous notes
--update M
--set M.[Analyst Notes]=M.[Analyst Notes]+' '+D.[Analyst Notes]
--from webapp.ManualAnalystUpdates M,
--webapp.MSFormsAnalystUpdatesLatestDetails D
--where M.[Project #]=D.[Project Number]
----and M.[Sub #]=D.[Project Sub Number(s)]
--and M.[Analyst Notes]!=D.[Analyst Notes]

--Parking zone
INSERT INTO [webapp].[MSFormsAnalystUpdates]
           ([SubmittedBy]
           ,[SubmitttedDtm]
           ,[Username (Frontier CORP ID)]
           ,[Project Number]
           ,[Project Sub Number(s)]
           ,[Spending Not Needed]
           ,[Future Spending]
           ,[Current Project Status]
           ,[Analyst Notes])
select
[User ID], [date], [User ID], [Project #],[Sub #],[Spend Not Needed]
,[Future Years Spending],[Current Project Status],[Analyst Notes]
from webapp.ManualAnalystUpdates

--Trim parking zone
update webapp.MSFormsAnalystUpdates
set [Spending Not Needed] = 0 where [Spending Not Needed] is null
update webapp.MSFormsAnalystUpdates
set [Future Spending] = 0 where [Future Spending] is null

truncate table webapp.ManualAnalystUpdates




UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_ManualAnalystUpdates P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_ManualAnalystUpdates

----------------------------------------------------------------------------------

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH