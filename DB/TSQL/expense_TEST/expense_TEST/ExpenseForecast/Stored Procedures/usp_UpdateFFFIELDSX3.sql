-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [expenseforecast].[usp_UpdateFFFIELDSX3]
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY
	BEGIN TRANSACTION

	DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateFFFIELDSX3
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateFFFIELDS]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateFFFIELDSX3
FROM [LOG].[Tracker]

------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #LZ
CREATE TABLE #LZ
(
    [ProjectNumber] [varchar](12) NULL,
    [SubprojectNumber] [varchar](7) NULL,
    [ClassOfPlant] [varchar](7) NULL,
    [LinkCode] [varchar](35) NULL,
    [JustificationCode] [varchar](15) NULL,
    [FunctionalGroup] [varchar](6) NULL,
    [ProjectDescription] [nvarchar](200) NULL,
    [ProjectStatusCode] [varchar](7) NULL,
    [ApprovalCode] [varchar](7) NULL,
    [ProjectType] [varchar](6) NULL,
    [Billable] [varchar](6) NULL,
    [Company] [varchar](10) NULL,
    [ExchangeNumber] [varchar](10) NULL,
    [OperatingArea] [varchar](8) NULL,
    [State] [varchar](7) NULL,
    [Engineer] [nvarchar](35) NULL,
    [ProjectOwner] [nvarchar](50) NULL,
    [ApprovalDate] [varchar](12) NULL,
    [EstimatedStartDate] [varchar](12) NULL,
    [EstimatedCompleteDate] [varchar](12) NULL,
    [ActualStartDate] [varchar](12) NULL,
    [ReadyForServiceDate] [varchar](12) NULL,
    [TentativeCloseDate] [varchar](12) NULL,
    [CloseDate] [varchar](12) NULL
)




BULK INSERT #LZ
FROM 'd:\DataDump\FFFIELDSX3.csv'
WITH
(
FIELDTERMINATOR='|'
,Rowterminator = '\n'
,codepage=65001
--,batchsize=500
--,format='csv'
--,fieldquote='"'
)



UPDATE #LZ
SET
ProjectNumber=REPLACE(ProjectNumber,'"',''),
SubprojectNumber=REPLACE(SubprojectNumber,'"',''),
ClassOfPlant=REPLACE(ClassOfPlant,'"',''),
LinkCode=REPLACE(LinkCode,'"',''),
JustificationCode=REPLACE(JustificationCode,'"',''),
FunctionalGroup=REPLACE(FunctionalGroup,'"',''),
ProjectDescription=REPLACE(ProjectDescription,'"',''),
ProjectStatusCode=REPLACE(ProjectStatusCode,'"',''),
ApprovalCode=REPLACE(ApprovalCode,'"',''),
ProjectType=REPLACE(ProjectType,'"',''),
Billable=REPLACE(Billable,'"',''),
Company=REPLACE(Company,'"',''),
ExchangeNumber=REPLACE(ExchangeNumber,'"',''),
OperatingArea=REPLACE(OperatingArea,'"',''),
State=REPLACE(State,'"',''),
Engineer=REPLACE(Engineer,'"',''),
ProjectOwner=REPLACE(ProjectOwner,'"',''),
ApprovalDate=REPLACE(ApprovalDate,'"',''),
EstimatedStartDate=REPLACE(EstimatedStartDate,'"',''),
EstimatedCompleteDate=REPLACE(EstimatedCompleteDate,'"',''),
ActualStartDate=REPLACE(ActualStartDate,'"',''),
ReadyForServiceDate=REPLACE(ReadyForServiceDate,'"',''),
TentativeCloseDate=REPLACE(TentativeCloseDate,'"',''),
CloseDate=REPLACE(CloseDate,'"','')

update #LZ set JustificationCode=null
where JustificationCode like '%[a-zA-Z]%'



--SELECT TOP 100 * FROM #LZ    



TRUNCATE TABLE [dbo].[FFFIELDS]



INSERT INTO dbo.FFFIELDS        
(
[ProjectNumber]
      ,[SubprojectNumber]
      ,[ClassOfPlant]
      ,[LinkCode]
      ,[JustificationCode]
      ,[FunctionalGroup]
      ,[ProjectDescription]
      ,[ProjectStatusCode]
      ,[ApprovalCode]
      ,[ProjectType]
      ,[Billable]
      ,[Company]
      ,[ExchangeNumber]
      ,[OperatingArea]
      ,[State]
      ,[Engineer]
      ,[ProjectOwner]
      ,[ApprovalDate]
      ,[EstimatedStartDate]
      ,[EstimatedCompleteDate]
      ,[ActualStartDate]
      ,[ReadyForServiceDate]
      ,[TentativeCloseDate]
      ,[CloseDate]
      )
SELECT [ProjectNumber]
      ,[SubprojectNumber]
      ,[ClassOfPlant]
      ,[LinkCode]
      ,[JustificationCode]
      ,[FunctionalGroup]
      ,[ProjectDescription]
      ,[ProjectStatusCode]
      ,[ApprovalCode]
      ,[ProjectType]
      ,[Billable]
      ,[Company]
      ,[ExchangeNumber]
      ,[OperatingArea]
      ,[State]
      ,[Engineer]
      ,[ProjectOwner]
      ,[ApprovalDate]
      ,[EstimatedStartDate]
      ,[EstimatedCompleteDate]
      ,[ActualStartDate]
      ,[ReadyForServiceDate]
      ,[TentativeCloseDate]
      ,[CloseDate]
FROM #LZ
DROP TABLE IF EXISTS  #LZ



UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateFFFIELDSX3 P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateFFFIELDSX3


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH