
CREATE PROCEDURE [ProjApproval].[usp_Compute_PreSale_BDT]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
	DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__usp_Compute_PreSale_BDT
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[usp_Compute_PreSale_BDT]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_FTTH__usp_Compute_PreSale_BDT
FROM [LOG].[Tracker]

-----------------------------------------------------------------------
--BDT CARRIER- PreSale NRC/MRC should be set equal to PostSale NRC/MRC
UPDATE [ProjApproval].[Compare_BDT_History_Trimmed]
SET [PreSale MRC] = [PostSale MRC],
[PreSale NRC] = [PostSale NRC]
WHERE [PostSale Retail OR Carrier] LIKE '%CARRIER%'
AND [PostSale Retail OR Carrier] NOT LIKE '%RET%'


--------------------------------------------------------------------------------
--DSAT PreSale OSP Capital
UPDATE ProjApproval.[Compare_BDT_History_Trimmed]
SET [PreSale OSP Capital] = [PostSale OSP Capital]/[PostSale Total Capital]*[PreSale Total NPV Capital]
where [PostSale PREQUAL TYPE] like '%DSAT%'
and [PostSale Total Capital] != 0
and [PostSale Total Capital] is not null

--------------------------------------------------------------------------------------------------
--Trim original data for NPV factors
TRUNCATE TABLE [ProjApproval].[Compute_PreSale_BDT]

INSERT INTO [ProjApproval].[Compute_PreSale_BDT]
           ([Opportunity ID]
           ,[PreSale ISP Capital]
           ,[PreSale OSP Capital]
           ,[PreSale Total Capital]
           ,[PreSale CIAC]
           ,[PreSale Term]
           ,[PreSale MRC]
           ,[PreSale NRC]
           ,[PreSale NPV]
           ,[PreSale IRR]
           ,[PreSale PAYBACK]
)
select
[Opportunity ID],
max([PreSale Total NPV Capital]-[PreSale OSP Capital]),
max([PreSale OSP Capital]),
max([PreSale Total NPV Capital]),
max([PreSale CIAC]),
max([PostSale Term Months]),
max([PreSale MRC]),
max([PreSale NRC]),
max([PreSale NPV]),
max([PreSale IRR]),
max([PreSale Payback])
from ProjApproval.Compare_BDT_History_Trimmed
group by [Opportunity ID]
--------------------------------------------------------------------------------------------------
update [ProjApproval].[Compute_PreSale_BDT]
set [PreSale Term] = 0
WHERE [PreSale Term] IS NULL

update [ProjApproval].[Compute_PreSale_BDT]
set [PreSale MRC] = 0
WHERE [PreSale MRC] IS NULL

update [ProjApproval].[Compute_PreSale_BDT]
set [PreSale NRC] = 0
WHERE [PreSale NRC] IS NULL

update [ProjApproval].[Compute_PreSale_BDT]
set [PreSale CIAC] = 0
WHERE [PreSale CIAC] IS NULL
--------------------------------------------------------------------------------------------------
update [ProjApproval].[Compute_PreSale_BDT]
set [PreSale Term] = [PreSale Term]/12

--update [ProjApproval].[Compute_PreSale_BDT]
--set [PreSale MRC] = [PreSale MRC]*12,
--[PreSale NRC] = [PreSale NRC]*12

--------------------------------------------------------------------------------------------------

--CIAC split into ISP and OSP
update ProjApproval.Compute_PreSale_BDT
set CIAC_ISP = [PreSale ISP Capital]/[PreSale Total Capital]*[PreSale CIAC]
WHERE [PreSale Total Capital] IS NOT NULL
AND [PreSale Total Capital] != 0
update ProjApproval.Compute_PreSale_BDT
set CIAC_OSP = [PreSale OSP Capital]/[PreSale Total Capital]*[PreSale CIAC]
WHERE [PreSale Total Capital] IS NOT NULL
AND [PreSale Total Capital] != 0




--------------------------------------------------------------------------------------------------
--Bring state
update PBDT
set [state] = HBDT.[PostSale STATE]
from ProjApproval.Compare_BDT_History_Trimmed as HBDT,
ProjApproval.Compute_PreSale_BDT as PBDT
where HBDT.[Opportunity ID] = PBDT.[Opportunity ID]
--Bring tax
	--Normal
		update PBDT
		set TaxRate = ITR.IncomeTaxRate
		from [ProjApproval].[Compute_PreSale_BDT] as PBDT,
		ProjApproval.IncomeTaxRate as ITR
		where PBDT.[State] = ITR.[State]
	--Zero
		update C
		set TaxRate = 0
		from [ProjApproval].[Compute_PreSale_BDT] as C,
		ProjApproval.Compare_BDT_History_Trimmed as H
		where C.[Opportunity ID] = H.[Opportunity ID]
		AND H.[PostSale Contract Signature/ASR Order] LIKE '%2020-%'
--Bring common capital
update PBDT
set [Common Capital] = HBDT.[PreSale Common Capital]
from ProjApproval.Compute_PreSale_BDT as PBDT,
ProjApproval.Compare_BDT_History_Trimmed as HBDT
where PBDT.[Opportunity ID] = HBDT.[Opportunity ID]
--Trim common capital
UPDATE ProjApproval.Compute_PreSale_BDT
set [Common Capital] = 0 WHERE [Common Capital] IS NULL
--------------------------------------------------------------------------------------------------
--Bring depreciation rates from depreciation rate table based on year, ISP/OSP, and term

update PBDT set [DepreciationISP1] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 1 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP2] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 2 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP3] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 3 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP4] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 4 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP5] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 5 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP6] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 6 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP7] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 7 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP8] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 8 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP9] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 9 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP10] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 10 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationISP11] = D.ISP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 11 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP1] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 1 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP2] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 2 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP3] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 3 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP4] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 4 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP5] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 5 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP6] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 6 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP7] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 7 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP8] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 8 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP9] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 9 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP10] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 10 and D.[Year] <= PBDT.[PreSale Term]
update PBDT set [DepreciationOSP11] = D.OSP from ProjApproval.Compute_PreSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 11 and D.[Year] <= PBDT.[PreSale Term]
--------------------------------------------------------------------------------------------------
--Trim depreciation data

update ProjApproval.Compute_PreSale_BDT set DepreciationISP1 = 0 where DepreciationISP1 is null or [PreSale Term] < 1
update ProjApproval.Compute_PreSale_BDT set DepreciationISP2 = 0 where DepreciationISP2 is null or [PreSale Term] < 2
update ProjApproval.Compute_PreSale_BDT set DepreciationISP3 = 0 where DepreciationISP3 is null or [PreSale Term] < 3
update ProjApproval.Compute_PreSale_BDT set DepreciationISP4 = 0 where DepreciationISP4 is null or [PreSale Term] < 4
update ProjApproval.Compute_PreSale_BDT set DepreciationISP5 = 0 where DepreciationISP5 is null or [PreSale Term] < 5
update ProjApproval.Compute_PreSale_BDT set DepreciationISP6 = 0 where DepreciationISP6 is null or [PreSale Term] < 6
update ProjApproval.Compute_PreSale_BDT set DepreciationISP7 = 0 where DepreciationISP7 is null or [PreSale Term] < 7
update ProjApproval.Compute_PreSale_BDT set DepreciationISP8 = 0 where DepreciationISP8 is null or [PreSale Term] < 8
update ProjApproval.Compute_PreSale_BDT set DepreciationISP9 = 0 where DepreciationISP9 is null or [PreSale Term] < 9
update ProjApproval.Compute_PreSale_BDT set DepreciationISP10 = 0 where DepreciationISP10 is null or [PreSale Term] < 10
update ProjApproval.Compute_PreSale_BDT set DepreciationISP11 = 0 where DepreciationISP11 is null or [PreSale Term] < 11
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP1 = 0 where DepreciationOSP1 is null or [PreSale Term] < 1
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP2 = 0 where DepreciationOSP2 is null or [PreSale Term] < 2
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP3 = 0 where DepreciationOSP3 is null or [PreSale Term] < 3
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP4 = 0 where DepreciationOSP4 is null or [PreSale Term] < 4
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP5 = 0 where DepreciationOSP5 is null or [PreSale Term] < 5
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP6 = 0 where DepreciationOSP6 is null or [PreSale Term] < 6
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP7 = 0 where DepreciationOSP7 is null or [PreSale Term] < 7
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP8 = 0 where DepreciationOSP8 is null or [PreSale Term] < 8
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP9 = 0 where DepreciationOSP9 is null or [PreSale Term] < 9
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP10 = 0 where DepreciationOSP10 is null or [PreSale Term] < 10
update ProjApproval.Compute_PreSale_BDT set DepreciationOSP11 = 0 where DepreciationOSP11 is null or [PreSale Term] < 11

------------------------------------------------------------------------------------------
--Trim Capital data

update [ProjApproval].[Compute_PreSale_BDT]
set [PreSale ISP Capital] = 0
WHERE [PreSale ISP Capital] IS NULL

update [ProjApproval].[Compute_PreSale_BDT]
set [PreSale OSP Capital] = 0
WHERE [PreSale OSP Capital] IS NULL

update [ProjApproval].[Compute_PreSale_BDT]
set [PreSale Total Capital] = 0
WHERE [PreSale Total Capital] IS NULL

---------------------------------------------------------------------------------------------------
--Computing depreciation $
declare @t Table (OppID [varchar] (50), NewYrHalf money, OldYrHalf money)
--Year 1 ISP Dep
UPDATE ProjApproval.Compute_PreSale_BDT 
SET [DepreciationISP1] = (([PreSale ISP Capital] - CIAC_ISP)*DepreciationISP1)/2 
where [PreSale Term] >=  1

--Year 2 ISP Dep
INSERT INTO @t (OppID,OldYrHalf)  
select [Opportunity ID],[DepreciationISP1] 
from ProjApproval.Compute_PreSale_BDT 
UPDATE @t
SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP2])/2
FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT
WHERE [@t].OppID = PBDT.[Opportunity ID]
UPDATE PBDT   
SET [DepreciationISP2]=NewYrHalf+OldYrHalf
from ProjApproval.Compute_PreSale_BDT AS PBDT, @t 
where PBDT.[PreSale Term] >= 2 AND [@t].OppID = PBDT.[Opportunity ID]

----year 3 and onwards ISP Dep

update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP3])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP3]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 3 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP4])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP4]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 4 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP5])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP5]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 5 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP6])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP6]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 6 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP7])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP7]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 7 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP8])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP8]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 8 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP9])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP9]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 9 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP10])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP10]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 10 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale ISP Capital]-CIAC_ISP)*[DepreciationISP11])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP11]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 11 AND [@t].OppID = PBDT.[Opportunity ID]

--Year 1 OSP Dep
UPDATE ProjApproval.Compute_PreSale_BDT 
SET [DepreciationOSP1] = (([PreSale OSP Capital] - CIAC_OSP)*DepreciationOSP1)/2 
where [PreSale Term] >=  1

--Year 2 OSP Dep
Delete from @t
INSERT INTO @t (OppID,OldYrHalf)  
select [Opportunity ID],[DepreciationOSP1] 
from ProjApproval.Compute_PreSale_BDT 
UPDATE @t
SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP2])/2
FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT
WHERE [@t].OppID = PBDT.[Opportunity ID]
UPDATE PBDT   
SET [DepreciationOSP2]=NewYrHalf+OldYrHalf
from ProjApproval.Compute_PreSale_BDT AS PBDT, @t 
where PBDT.[PreSale Term] >= 2 AND [@t].OppID = PBDT.[Opportunity ID]

--year 3 and onwards OSP Dep

update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP3])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP3]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 3 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP4])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP4]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 4 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP5])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP5]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 5 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP6])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP6]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 6 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP7])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP7]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 7 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP8])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP8]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 8 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP9])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP9]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 9 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP10])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP10]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 10 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PreSale OSP Capital]-CIAC_OSP)*[DepreciationOSP11])/2 FROM @t, ProjApproval.Compute_PreSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP11]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PreSale_BDT AS PBDT, @t  where PBDT.[PreSale Term] >= 11 AND [@t].OppID = PBDT.[Opportunity ID]



----test
--select OppId, NewYrHalf, OldYrHalf from @t

----------------------------------------------------------------------------------------------------
--Compute tax
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX1 = ([PreSale MRC] * 12 + [PreSale NRC] - DepreciationISP1 - DepreciationOSP1) * TaxRate
where [PreSale Term] >=  1
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX2 = ([PreSale MRC] * 12 - DepreciationISP2 - DepreciationOSP2) * TaxRate
where [PreSale Term] >=  2
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX3 = ([PreSale MRC] * 12 - DepreciationISP3 - DepreciationOSP3) * TaxRate
where [PreSale Term] >=  3
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX4 = ([PreSale MRC] * 12 - DepreciationISP4 - DepreciationOSP4) * TaxRate
where [PreSale Term] >=  4
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX5 = ([PreSale MRC] * 12 - DepreciationISP5 - DepreciationOSP5) * TaxRate
where [PreSale Term] >=  5
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX6 = ([PreSale MRC] * 12 - DepreciationISP6 - DepreciationOSP6) * TaxRate
where [PreSale Term] >=  6
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX7 = ([PreSale MRC] * 12 - DepreciationISP7 - DepreciationOSP7) * TaxRate
where [PreSale Term] >=  7
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX8 = ([PreSale MRC] * 12 - DepreciationISP8 - DepreciationOSP8) * TaxRate
where [PreSale Term] >=  8
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX9 = ([PreSale MRC] * 12 - DepreciationISP9 - DepreciationOSP9) * TaxRate
where [PreSale Term] >=  9
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX10 = ([PreSale MRC] * 12 - DepreciationISP10 - DepreciationOSP10) * TaxRate
where [PreSale Term] >=  10
UPDATE ProjApproval.Compute_PreSale_BDT
SET TAX11 = ([PreSale MRC] * 12 - DepreciationISP11 - DepreciationOSP11) * TaxRate
where [PreSale Term] >=  11

--------------------------------------------------------------------------------------------------
--Set discount rate
update ProjApproval.Compute_PreSale_BDT
set DiscountRate = 0.15
--------------------------------------------------------------------------------------------------
--Trim tax
update ProjApproval.Compute_PreSale_BDT
set TAX1 = 0 where Tax1 is null OR [PreSale Term] < 1
update ProjApproval.Compute_PreSale_BDT
set TAX2 = 0 where Tax2 is null OR [PreSale Term] < 2
update ProjApproval.Compute_PreSale_BDT
set TAX3 = 0 where Tax3 is null OR [PreSale Term] < 3
update ProjApproval.Compute_PreSale_BDT
set TAX4 = 0 where Tax4 is null OR [PreSale Term] < 4
update ProjApproval.Compute_PreSale_BDT
set TAX5 = 0 where Tax5 is null OR [PreSale Term] < 5
update ProjApproval.Compute_PreSale_BDT
set TAX6 = 0 where Tax6 is null OR [PreSale Term] < 6
update ProjApproval.Compute_PreSale_BDT
set TAX7 = 0 where Tax7 is null OR [PreSale Term] < 7
update ProjApproval.Compute_PreSale_BDT
set TAX8 = 0 where Tax8 is null OR [PreSale Term] < 8
update ProjApproval.Compute_PreSale_BDT
set TAX9 = 0 where Tax9 is null OR [PreSale Term] < 9
update ProjApproval.Compute_PreSale_BDT
set TAX10 = 0 where Tax10 is null OR [PreSale Term] < 10
update ProjApproval.Compute_PreSale_BDT
set TAX11 = 0 where Tax11 is null OR [PreSale Term] < 11
--------------------------------------------------------------------------------------------------
--Compute NPV
--Get cash flows for each valid year
Declare @CF table 
(OppID [varchar](50)
,CF0 money
,CF1 money
,CF2 money
,CF3 money
,CF4 money
,CF5 money
,CF6 money
,CF7 money
,CF8 money
,CF9 money
,CF10 money
,CF11 money
)
INSERT INTO @CF (OppID) select [Opportunity ID] from ProjApproval.Compute_PreSale_BDT
update @CF
set CF0 = -([PreSale Total Capital] - [Common Capital] - [PreSale CIAC])
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]

update @CF
set CF1 = (([PreSale MRC]*12.0 + [PreSale NRC] - Tax1)/(Power(1.0+DiscountRate, 1.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax1 != 0

update @CF
set CF2 = (([PreSale MRC]*12.0 - Tax2)/(Power(1.0+DiscountRate, 2.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax2 != 0

update @CF
set CF3 = (([PreSale MRC]*12.0 - Tax3)/(Power(1.0+DiscountRate, 3.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax3 != 0

update @CF
set CF4 = (([PreSale MRC]*12.0 - Tax4)/(Power(1.0+DiscountRate, 4.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax4 != 0

update @CF
set CF5 = (([PreSale MRC]*12.0 - Tax5)/(Power(1.0+DiscountRate, 5.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax5 != 0

update @CF
set CF6 = (([PreSale MRC]*12.0 - Tax6)/(Power(1.0+DiscountRate, 6.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax6 != 0

update @CF
set CF7 = (([PreSale MRC]*12.0 - Tax7)/(Power(1.0+DiscountRate, 7.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax7 != 0

update @CF
set CF8 = (([PreSale MRC]*12.0 - Tax8)/(Power(1.0+DiscountRate, 8.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax8 != 0

update @CF
set CF9 = (([PreSale MRC]*12.0 - Tax9)/(Power(1.0+DiscountRate, 9.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax9 != 0

update @CF
set CF10 = (([PreSale MRC]*12.0 - Tax10)/(Power(1.0+DiscountRate, 10.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax10 != 0

update @CF
set CF11 = (([PreSale MRC]*12.0 - Tax11)/(Power(1.0+DiscountRate, 11.0)))
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax11 != 0


--Get NPV for each valid year
update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 1

update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1+CF2
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 2

update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1+CF2+CF3
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 3

update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1+CF2+CF3+CF4
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 4

update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 5

update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 6

update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 7

update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 8

update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8+CF9
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 9

update ProjApproval.Compute_PreSale_BDT
set [PreSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8+CF9+CF10
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] = 10

--Bring NPV to history trimmed table for each opportunity
update HBDT
set [PreSale NPV] = PBDT.[PreSale NPV]
from ProjApproval.Compare_BDT_History_Trimmed as HBDT,
ProjApproval.Compute_PreSale_BDT as PBDT
where HBDT.[Opportunity ID] = PBDT.[Opportunity ID]

------------------------------------------------------------------
--Compute IRR https://xplaind.com/484996/irr
--Trim @CF table
update @CF set CF0 = 0 where CF0 is null
update @CF set CF1 = 0 where CF1 is null
update @CF set CF2 = 0 where CF2 is null
update @CF set CF3 = 0 where CF3 is null
update @CF set CF4 = 0 where CF4 is null
update @CF set CF5 = 0 where CF5 is null
update @CF set CF6 = 0 where CF6 is null
update @CF set CF7 = 0 where CF7 is null
update @CF set CF8 = 0 where CF8 is null
update @CF set CF9 = 0 where CF9 is null
update @CF set CF10 = 0 where CF10 is null
update @CF set CF11 = 0 where CF11 is null

--Undiscount cash flows
update @CF
set CF0 = -([PreSale Total Capital] - [Common Capital] - [PreSale CIAC])
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]

update @CF
set CF1 = [PreSale MRC]*12.0 + [PreSale NRC] - Tax1
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax1 != 0

update @CF
set CF2 = [PreSale MRC]*12.0 - Tax2
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax2 != 0

update @CF
set CF3 = [PreSale MRC]*12.0 - Tax3
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax3 != 0

update @CF
set CF4 = [PreSale MRC]*12.0 - Tax4
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax4 != 0

update @CF
set CF5 = [PreSale MRC]*12.0 - Tax5
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax5 != 0

update @CF
set CF6 = [PreSale MRC]*12.0 - Tax6
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax6 != 0

update @CF
set CF7 = [PreSale MRC]*12.0 - Tax7
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax7 != 0

update @CF
set CF8 = [PreSale MRC]*12.0 - Tax8
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax8 != 0

update @CF
set CF9 = [PreSale MRC]*12.0 - Tax9
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax9 != 0

update @CF
set CF10 = [PreSale MRC]*12.0 - Tax10
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax10 != 0

update @CF
set CF11 = [PreSale MRC]*12.0 - Tax11
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax11 != 0

--Copy cash flow to history trimmed table
UPDATE HBDT
set [C0] = [@CF].[CF0]
, [C1] = [@CF].[CF1]
, [C2] = [@CF].[CF2]
, [C3] = [@CF].[CF3]
, [C4] = [@CF].[CF4]
, [C5] = [@CF].[CF5]
, [C6] = [@CF].[CF6]
, [C7] = [@CF].[CF7]
, [C8] = [@CF].[CF8]
, [C9] = [@CF].[CF9]
, [C10] = [@CF].[CF10]
, [C11] = [@CF].[CF11]
from ProjApproval.Compare_BDT_History_Trimmed AS HBDT, @CF
WHERE HBDT.[Opportunity ID] = [@CF].OppID


-----------------------------------------------------------------------------------
----Payback https://xplaind.com/849768/payback-period


--Get cummulative cash flows for each valid year
update ProjApproval.Compute_PreSale_BDT
set CC0 = CF0
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 0

update ProjApproval.Compute_PreSale_BDT
set CC1 = CF0+CF1
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 1

update ProjApproval.Compute_PreSale_BDT
set CC2 = CF0+CF1+CF2
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 2

update ProjApproval.Compute_PreSale_BDT
set CC3 = CF0+CF1+CF2+CF3
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 3

update ProjApproval.Compute_PreSale_BDT
set CC4 = CF0+CF1+CF2+CF3+CF4
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 4

update ProjApproval.Compute_PreSale_BDT
set CC5 = CF0+CF1+CF2+CF3+CF4+CF5
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 5

update ProjApproval.Compute_PreSale_BDT
set CC6 = CF0+CF1+CF2+CF3+CF4+CF5+CF6
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 6

update ProjApproval.Compute_PreSale_BDT
set CC7 = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 7

update ProjApproval.Compute_PreSale_BDT
set CC8 = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 8

update ProjApproval.Compute_PreSale_BDT
set CC9 = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8+CF9
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 9

update ProjApproval.Compute_PreSale_BDT
set CC10 = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8+CF9+CF10
from @CF, ProjApproval.Compute_PreSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PreSale Term] >= 10

update ProjApproval.Compute_PreSale_BDT set CC1=0 WHERE CC1=CC0
update ProjApproval.Compute_PreSale_BDT set CC2=0 WHERE CC2=CC1 OR CC2=CC1 OR CC2=CC0
update ProjApproval.Compute_PreSale_BDT set CC3=0 WHERE CC3=CC2 OR CC3=CC1 OR CC3=CC0
update ProjApproval.Compute_PreSale_BDT set CC4=0 WHERE CC4=CC3 OR CC4=CC2 OR CC4=CC1 OR CC4=CC0
update ProjApproval.Compute_PreSale_BDT set CC5=0 WHERE CC5=CC4 OR CC5=CC3 OR CC5=CC2 OR CC5=CC1 OR CC5=CC0
update ProjApproval.Compute_PreSale_BDT set CC6=0 WHERE CC6=CC5 OR CC6=CC4 OR CC6=CC3 OR CC6=CC2 OR CC6=CC1 OR CC6=CC0
update ProjApproval.Compute_PreSale_BDT set CC7=0 WHERE CC7=CC6 OR CC7=CC5 OR CC7=CC4 OR CC7=CC3 OR CC7=CC2 OR CC7=CC1 OR CC7=CC0
update ProjApproval.Compute_PreSale_BDT set CC8=0 WHERE CC8=CC7 OR CC8=CC6 OR CC8=CC5 OR CC8=CC4 OR CC8=CC3 OR CC8=CC2 OR CC8=CC1 OR CC8=CC0
update ProjApproval.Compute_PreSale_BDT set CC9=0 WHERE CC9=CC8 OR CC9=CC7 OR CC9=CC6 OR CC9=CC5 OR CC9=CC4 OR CC9=CC3 OR CC9=CC2 OR CC9=CC1 OR CC9=CC0
update ProjApproval.Compute_PreSale_BDT set CC10=0 WHERE CC10=CC9 OR CC10=CC8 OR CC10=CC7 OR CC10=CC6 OR CC10=CC5 OR CC10=CC4 OR CC10=CC3 OR CC10=CC2 OR CC10=CC1 OR CC10=CC0
update ProjApproval.Compute_PreSale_BDT set CC11=0 WHERE CC11=CC10 OR CC11=CC9 OR CC11=CC8 OR CC11=CC7 OR CC11=CC6 OR CC11=CC5 OR CC11=CC4 OR CC11=CC3 OR CC11=CC2 OR CC11=CC1 OR CC11=CC0

--Copy cumulative cashflows into presale history table
update HBDT
set HBDT.CC0 = PBDT.CC0
,HBDT.CC1 = PBDT.CC1
,HBDT.CC2 = PBDT.CC2
,HBDT.CC3 = PBDT.CC3
,HBDT.CC4 = PBDT.CC4
,HBDT.CC5 = PBDT.CC5
,HBDT.CC6 = PBDT.CC6
,HBDT.CC7 = PBDT.CC7
,HBDT.CC8 = PBDT.CC8
,HBDT.CC9 = PBDT.CC9
,HBDT.CC10 = PBDT.CC10
,HBDT.CC11 = PBDT.CC11
from ProjApproval.Compare_BDT_History_Trimmed as HBDT,
ProjApproval.Compute_PreSale_BDT as PBDT
where HBDT.[Opportunity ID] = PBDT.[Opportunity ID]

--Trim cummulative cash flow data in history table
update ProjApproval.Compare_BDT_History_Trimmed set CC0=0 where CC0 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC1=0 where CC1 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC2=0 where CC2 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC3=0 where CC3 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC4=0 where CC4 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC5=0 where CC5 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC6=0 where CC6 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC7=0 where CC7 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC8=0 where CC8 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC9=0 where CC9 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC10=0 where CC10 is null
update ProjApproval.Compare_BDT_History_Trimmed set CC11=0 where CC11 is null


--Get individual payback for each year
update ProjApproval.Compute_PreSale_BDT set P0=0+(1-CC1/(CC1-CC0)) where CC0<0 and CC1>0
update ProjApproval.Compute_PreSale_BDT set P1=1+(1-CC2/(CC2-CC1)) where CC1<0 and CC2>0
update ProjApproval.Compute_PreSale_BDT set P2=2+(1-CC3/(CC3-CC2)) where CC2<0 and CC3>0
update ProjApproval.Compute_PreSale_BDT set P3=3+(1-CC4/(CC4-CC3)) where CC3<0 and CC4>0
update ProjApproval.Compute_PreSale_BDT set P4=4+(1-CC5/(CC5-CC4)) where CC4<0 and CC5>0
update ProjApproval.Compute_PreSale_BDT set P5=5+(1-CC6/(CC6-CC5)) where CC5<0 and CC6>0
update ProjApproval.Compute_PreSale_BDT set P6=6+(1-CC7/(CC7-CC6)) where CC6<0 and CC7>0
update ProjApproval.Compute_PreSale_BDT set P7=7+(1-CC8/(CC8-CC7)) where CC7<0 and CC8>0
update ProjApproval.Compute_PreSale_BDT set P8=8+(1-CC9/(CC9-CC8)) where CC8<0 and CC9>0
update ProjApproval.Compute_PreSale_BDT set P9=9+(1-CC10/(CC10-CC9)) where CC9<0 and CC10>0
update ProjApproval.Compute_PreSale_BDT set P10=10+(1-CC11/(CC11-CC10)) where CC10<0 and CC11>0

--Trim individual payback data for each year
update ProjApproval.Compute_PreSale_BDT set P0=0 WHERE P0 IS NULL
update ProjApproval.Compute_PreSale_BDT set P1=0 WHERE P1 IS NULL
update ProjApproval.Compute_PreSale_BDT set P2=0 WHERE P2 IS NULL
update ProjApproval.Compute_PreSale_BDT set P3=0 WHERE P3 IS NULL
update ProjApproval.Compute_PreSale_BDT set P4=0 WHERE P4 IS NULL
update ProjApproval.Compute_PreSale_BDT set P5=0 WHERE P5 IS NULL
update ProjApproval.Compute_PreSale_BDT set P6=0 WHERE P6 IS NULL
update ProjApproval.Compute_PreSale_BDT set P7=0 WHERE P7 IS NULL
update ProjApproval.Compute_PreSale_BDT set P8=0 WHERE P8 IS NULL
update ProjApproval.Compute_PreSale_BDT set P9=0 WHERE P9 IS NULL
update ProjApproval.Compute_PreSale_BDT set P10=0 WHERE P10 IS NULL
update ProjApproval.Compute_PreSale_BDT set P11=0 WHERE P11 IS NULL

--Final payback
update ProjApproval.Compute_PreSale_BDT 
set [PreSale PAYBACK] = P0+P1+P2+P3+P4+P5+P6+P7+P8+P9+P10

update ProjApproval.Compute_PreSale_BDT 
set [PreSale PAYBACK] = 0
where [PreSale PAYBACK] < 0

--Copy payback to original table
update HBDT

set [PreSale Payback] = PBDT.[PreSale PAYBACK]
from ProjApproval.Compare_BDT_History_Trimmed as HBDT,
ProjApproval.Compute_PreSale_BDT as PBDT
where HBDT.[Opportunity ID] = PBDT.[Opportunity ID]

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_FTTH__usp_Compute_PreSale_BDT P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__usp_Compute_PreSale_BDT


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
