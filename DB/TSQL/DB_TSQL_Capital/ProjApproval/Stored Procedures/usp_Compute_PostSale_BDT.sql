
CREATE PROCEDURE [ProjApproval].[usp_Compute_PostSale_BDT]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION
-----------------------------------------------------------------------
DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__usp_Compute_PostSale_BDT
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[usp_Compute_PostSale_BDT]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_FTTH__usp_Compute_PostSale_BDT
FROM [LOG].[Tracker]

----Import DSAT PostSale data into the DB
--TRUNCATE TABLE projapproval.postsale_dsat_history
--bulk insert projapproval.postsale_dsat_history
--from '\\nspinfwcipp01\Capital_Management\Capital Management Application\Project Approval Tracking\Development\BDT\PostSale_DSAT_History.txt'
--with (firstrow = 2)

--Bring original DSAT PostSale data into History compare table
delete from [ProjApproval].[Compare_BDT_History_Trimmed]
where [PostSale PREQUAL TYPE] like '%DSAT%'
INSERT INTO [ProjApproval].[Compare_BDT_History_Trimmed]
           ([Opportunity ID],
      [PostSale STATE],
      [PostSale PROJECT],
      [PostSale SUB-PROJECT],
      [PostSale CIAC],
      [PostSale PREQUAL TYPE],
      [PostSale PREQUAL # (BDT/DSAT)],
      [PostSale DSAT Lit Building?],
      [PostSale ORDER # (STATS/SF/ASR)],
      [PostSale CUST NAME],
      [PostSale DSAT TIERS],
      [PostSale DSAT BW],
      [PostSale PREQUAL (BDT/DSAT) $],
      [PostSale BDT YR APPRVD],
      [PostSale Retail OR Carrier],
      [PostSale Term Months],
      [PostSale MRC],
      [PostSale NRC],
      [PostSale Contract Signature/ASR Order],
      [PostSale VARASSET TICKET],
      [PreSale OSP Capital],
      [PreSale Total NPV Capital],
      [PreSale Common Capital],
      [PreSale MRC],
      [PreSale NRC],
      [PreSale CIAC]
)
select DISTINCT
[Opportunity ID],
      [STATE],
      [PROJECT],
      [SUB-PROJECT],
      [CIAC],
      [PREQUAL TYPE],
      [PREQUAL # (BDT/DSAT)],
[DSAT Lit Building?],
[ORDER # (STATS SF ASR)],
[CUST NAME],
[DSAT TIERS],
[DSAT BW],
      [PREQUAL $ (BDT/DSAT)],
[BDT YR APPRVD],
      [RETAIL OR CARRIER],
      [TERM Months],
      [MRC],
      [NRC],
cast([Contract Signature ASR Order] as date),
[VARASSET TICKET],
0,
      [PREQUAL $ (BDT/DSAT)],
0,
[MRC],
[NRC],
[CIAC]
from ProjApproval.PostSale_DSAT_History
where 
(
	ProjApproval.PostSale_DSAT_History.[Opportunity ID]
	NOT IN (
	select [Opportunity ID] from ProjApproval.[Compare_BDT_History_Trimmed])
)
OR 
(	
	(
		ProjApproval.PostSale_DSAT_History.PROJECT
		NOT IN (
		select [PostSale PROJECT] from ProjApproval.[Compare_BDT_History_Trimmed])
	)

AND
	(
		ProjApproval.PostSale_DSAT_History.[SUB-PROJECT]
		NOT IN (
		select [PostSale SUB-PROJECT] from ProjApproval.[Compare_BDT_History_Trimmed])
	)
)
----------------------------------------------------------------------
----Import BDT PostSale data into the DB
--delete from projapproval.compare_bdt_history_lz
--BULK INSERT projapproval.compare_bdt_history_lz
--from '\\nspinfwcipp01\Capital_Management\Capital Management Application\Project Approval Tracking\Development\BDT\Compare_BDT_History.txt'
--with (firstrow = 2)

INSERT INTO [ProjApproval].[Compare_BDT_History_Trimmed]
           ([Opportunity ID]
           ,[PostSale STATE]
           ,[PostSale PROJECT]
           ,[PostSale SUB-PROJECT]
           ,[PostSale CIAC]
           ,[PostSale PREQUAL TYPE]
           ,[PostSale PREQUAL # (BDT/DSAT)]
           ,[PostSale DSAT Lit Building?]
           ,[PostSale ORDER # (STATS/SF/ASR)]
           ,[PostSale CUST NAME]
           ,[PostSale DSAT TIERS]
           ,[PostSale DSAT BW]
           ,[PostSale PREQUAL (BDT/DSAT) $]
           ,[PostSale BDT YR APPRVD]
           ,[PostSale Retail OR Carrier]
           ,[PostSale Term Months]
           ,[PostSale MRC]
           ,[PostSale NRC]
           ,[PostSale Contract Signature/ASR Order]
           ,[PostSale VARASSET TICKET]
           ,[PreSale Exchange]
           ,[PreSale OSP Capital]
           ,[PreSale Total NPV Capital]
           ,[PreSale Common Capital]
           ,[PreSale MRC]
           ,[PreSale NRC]
           ,[PreSale CIAC]
           ,[PreSale NPV]
           ,[PreSale IRR]
           ,[PreSale Payback])
select [Opportunity ID]
           ,[PostSale STATE]
           ,[PostSale PROJECT]
           ,[PostSale SUB-PROJECT]
           ,[PostSale CIAC]
           ,[PostSale PREQUAL TYPE]
           ,[PostSale PREQUAL # (BDT/DSAT)]
           ,[PostSale DSAT Lit Building?]
           ,[PostSale ORDER # (STATS/SF/ASR)]
           ,[PostSale CUST NAME]
           ,[PostSale DSAT TIERS]
           ,[PostSale DSAT BW]
           ,[PostSale PREQUAL (BDT/DSAT) $]
           ,[PostSale BDT YR APPRVD]
           ,[PostSale Retail OR Carrier]
           ,[PostSale Term Months]
           ,[PostSale MRC]
           ,[PostSale NRC]
           ,[PostSale Contract Signature/ASR Order]
           ,[PostSale VARASSET TICKET]
           ,[PreSale Exchange]
           ,[PreSale OSP Capital]
           ,[PreSale Total NPV Capital]
           ,[PreSale Common Capital]
           ,[PreSale MRC]
           ,[PreSale NRC]
           ,[PreSale CIAC]
           ,[PreSale NPV]
           ,[PreSale IRR]
           ,[PreSale Payback]
from ProjApproval.Compare_BDT_History_LZ
where 
(
	ProjApproval.[Compare_BDT_History_LZ].[Opportunity ID]
	NOT IN (
	select [Opportunity ID] from ProjApproval.[Compare_BDT_History_Trimmed])
)
OR 
(	
	(
		ProjApproval.[Compare_BDT_History_LZ].[PostSale PROJECT]
		NOT IN (
		select [PostSale PROJECT] from ProjApproval.[Compare_BDT_History_Trimmed])
	)

AND
	(
		ProjApproval.[Compare_BDT_History_LZ].[PostSale SUB-PROJECT]
		NOT IN (
		select [PostSale SUB-PROJECT] from ProjApproval.[Compare_BDT_History_Trimmed])
	)
)
-----------------------------------------------------------------------
--BDT CARRIER- PreSale NRC/MRC should be set equal to PostSale NRC/MRC
UPDATE [ProjApproval].[Compare_BDT_History_Trimmed]
SET [PreSale MRC] = [PostSale MRC],
[PreSale NRC] = [PostSale NRC]
WHERE [PostSale Retail OR Carrier] LIKE '%CARRIER%'
AND [PostSale Retail OR Carrier] NOT LIKE '%RET%'


-----------------------------------------------------------------------
--DSAT- PreSale NRC/MRC should be set equal to PostSale NRC/MRC
UPDATE [ProjApproval].[Compare_BDT_History_Trimmed]
SET [PreSale MRC] = [PostSale MRC],
[PreSale NRC] = [PostSale NRC]
WHERE [Opportunity ID] like '%DSAT%'

----------------------------------------------------------------------------------------------------
--Trim original data for NPV factors
DELETE FROM [ProjApproval].[Compute_PostSale_BDT]

--Bring opps, proj, subproj from history to compute table 
INSERT INTO [ProjApproval].[Compute_PostSale_BDT]
([Opportunity ID], ProjectNumber, SubProjectNumber)
SELECT DISTINCT [Opportunity ID], [PostSale PROJECT], [PostSale SUB-PROJECT]
from ProjApproval.Compare_BDT_History_Trimmed

--Bring aggregate capital and revenue from history to compute table for OppID
declare @AggCap table (OppID varchar (50), ISP money, OSP money, total money, ciac money, term float, mrc money, nrc money)
INSERT INTO @AggCap (OppID,ISP,OSP,total,ciac,term,mrc,nrc)
select
distinct [Opportunity ID],
sum([PostSale Total Capital]-[PostSale OSP Capital]),
sum([PostSale OSP Capital]),
sum([PostSale Total Capital]),
sum([PostSale CIAC]),
max([PostSale Term Months]),
sum([PostSale MRC]),
sum([PostSale NRC])
from ProjApproval.Compare_BDT_History_Trimmed
group by [Opportunity ID]

update PBDT
SET PBDT.[PostSale OSP Capital] = A.OSP,
PBDT.[PostSale ISP Capital] = A.ISP,
PBDT.[PostSale Total Capital] = A.total,
PBDT.[PostSale CIAC] = A.ciac,
PBDT.[PostSale Term] = A.term,
PBDT.[PostSale MRC] = A.mrc,
PBDT.[PostSale NRC] = A.nrc
FROM ProjApproval.Compute_PostSale_BDT AS PBDT, @AggCap AS A
WHERE PBDT.[Opportunity ID] = A.OppID

--------------------------------------------------------------------------------------------------
--Trim some data
update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale Term] = 0
WHERE [PostSale Term] IS NULL
update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale MRC] = 0
WHERE [PostSale MRC] IS NULL

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale NRC] = 0
WHERE [PostSale NRC] IS NULL

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale CIAC] = 0
WHERE [PostSale CIAC] IS NULL

--Trim Capital data

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale ISP Capital] = 0
WHERE [PostSale ISP Capital] IS NULL

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale OSP Capital] = 0
WHERE [PostSale OSP Capital] IS NULL

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale Total Capital] = 0
WHERE [PostSale Total Capital] IS NULL
--------------------------------------------------------------------------------------------------
--Convert term from monthly to annual
update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale Term] = [PostSale Term]/12

--------------------------------------------------------------------------------------------------
--Reveal PostSale Capital
create table ProjApproval.GACapSplit (OppId [varchar](50), Proj int, Sub smallint, ISP money, OSP money)
insert into ProjApproval.GACapSplit (OppId, Proj, Sub)
select distinct [Opportunity ID], ProjectNumber, SubProjectNumber
from ProjApproval.Compute_PostSale_BDT

update ProjApproval.GACapSplit
set isp = 0 where isp is null
update ProjApproval.GACapSplit
set osp = 0 where osp is null

--Bring buks from GA
SELECT ProjApproval.GACapSplit.OppId, ProjApproval.GACapSplit.Proj, ProjApproval.GACapSplit.Sub, ProjApproval.GACapSplit.ISP, ProjApproval.GACapSplit.OSP, history.GALisa.GAMTSK, history.GALisa.GASTSK, SUM(CAST(history.GALisa.GARPT$ AS MONEY)) as Buks
INTO PROJAPPROVAL.GACAPSPLIT2
FROM     ProjApproval.GACapSplit left outer JOIN
                  history.GALisa ON ProjApproval.GACapSplit.Proj = history.GALisa.GAPRJ# AND ProjApproval.GACapSplit.Sub = history.GALisa.GAPRJS
GROUP BY ProjApproval.GACapSplit.OppId, ProjApproval.GACapSplit.Proj, ProjApproval.GACapSplit.Sub, ProjApproval.GACapSplit.ISP, ProjApproval.GACapSplit.OSP, history.GALisa.GAMTSK, history.GALisa.GASTSK
order by ProjApproval.GACapSplit.OppId, ProjApproval.GACapSplit.Proj, ProjApproval.GACapSplit.Sub

update ProjApproval.GACapSplit2
set isp = 0 where isp is null
update ProjApproval.GACapSplit2
set osp = 0 where osp is null
--OSP import from GA
update PROJAPPROVAL.GACAPSPLIT2
set OSP = Buks
where LEFT(GAMTSK,2) = '24'
or (GAMTSK = 2772 AND (LEFT(GASTSK,2) BETWEEN 11 AND 31))
or (GAMTSK BETWEEN 2790 AND 2799)

--ISP import from GA
update PROJAPPROVAL.GACAPSPLIT2
set ISP = Buks
WHERE LEFT(GAMTSK,2) = '21'
OR LEFT(GAMTSK,2) = '22'
OR LEFT(GAMTSK,2) = '23'
OR LEFT(GAMTSK,2) = '26'
OR (GAMTSK BETWEEN 2701 AND 2782)
OR (GAMTSK = 2772 AND (LEFT(GASTSK,2) BETWEEN 35 AND 90))

--ISP/OSP from GA compiled
SELECT DISTINCT [OppId]
      ,[Proj]
      ,[Sub]
      ,SUM([ISP]) AS ISP
      ,SUM([OSP]) AS OSP
INTO [ProjApproval].[GACAPSPLIT3]
  FROM [ProjApproval].[GACAPSPLIT2]
GROUP BY [OppId]
      ,[Proj]
      ,[Sub]

update ProjApproval.GACapSplit3
set isp = 0 where isp is null
update ProjApproval.GACapSplit3
set osp = 0 where osp is null

--Trim Capital data

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale ISP Capital] = 0
WHERE [PostSale ISP Capital] IS NULL

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale OSP Capital] = 0
WHERE [PostSale OSP Capital] IS NULL

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale Total Capital] = 0
WHERE [PostSale Total Capital] IS NULL

update ProjApproval.GACapSplit3
set isp = 0 where isp is null
update ProjApproval.GACapSplit3
set osp = 0 where osp is null

--ISP/OSP from GA summed up for opp id
select distinct oppid, sum(isp) as isp, sum(osp) as osp
into ProjApproval.GACAPSPLIT4
from ProjApproval.GACAPSPLIT3
group by oppid


--Bring OSP/ISP split into compute table
UPDATE PBDT
SET [PostSale ISP Capital]=GS.ISP,
[PostSale OSP Capital]=GS.OSP
FROM ProjApproval.Compute_PostSale_BDT PBDT, ProjApproval.GACapSplit4 GS
WHERE PBDT.[Opportunity ID]=GS.OppId
UPDATE PROJAPPROVAL.Compute_PostSale_BDT 
SET [PostSale Total Capital] = cast([PostSale ISP Capital] as float)+cast([PostSale OSP Capital] as float)


DROP TABLE ProjApproval.GACapSplit
DROP TABLE ProjApproval.GACapSplit2
DROP TABLE ProjApproval.GACapSplit3
DROP TABLE ProjApproval.GACapSplit4
----------------------------------------------------------------------------------------------------

--CIAC split into ISP and OSP
update ProjApproval.Compute_PostSale_BDT
set CIAC_ISP = [PostSale ISP Capital]/[PostSale Total Capital]*[PostSale CIAC]
WHERE [PostSale Total Capital] IS NOT NULL
AND [PostSale Total Capital] != 0
update ProjApproval.Compute_PostSale_BDT
set CIAC_OSP = [PostSale OSP Capital]/[PostSale Total Capital]*[PostSale CIAC]
WHERE [PostSale Total Capital] IS NOT NULL
AND [PostSale Total Capital] != 0


--------------------------------------------------------------------------------------------------
--Bring state
update PBDT
set [state] = HBDT.[PostSale STATE]
from ProjApproval.Compare_BDT_History_Trimmed as HBDT,
ProjApproval.Compute_PostSale_BDT as PBDT
where HBDT.[Opportunity ID] = PBDT.[Opportunity ID]
--Bring tax
	--Normal
		update PBDT
		set TaxRate = ITR.IncomeTaxRate
		from [ProjApproval].[Compute_PostSale_BDT] as PBDT,
		ProjApproval.IncomeTaxRate as ITR
		where PBDT.[State] = ITR.[State]

	--Zero
		update C
		set TaxRate = 0
		from [ProjApproval].[Compute_PostSale_BDT] as C,
		ProjApproval.Compare_BDT_History_Trimmed as H
		where C.[Opportunity ID] = H.[Opportunity ID]
		AND H.[PostSale Contract Signature/ASR Order] LIKE '%2020-%'
--Bring common capital
update PBDT
set [Common Capital] = HBDT.[PostSale Common Capital]
from ProjApproval.Compute_PostSale_BDT as PBDT,
ProjApproval.Compare_BDT_History_Trimmed as HBDT
where PBDT.[Opportunity ID] = HBDT.[Opportunity ID]
--Trim common capital
UPDATE ProjApproval.Compute_PostSale_BDT
set [Common Capital] = 0 WHERE [Common Capital] IS NULL
--------------------------------------------------------------------------------------------------
--Bring depreciation rates from depreciation rate table based on year, ISP/OSP, and term

update PBDT set [DepreciationISP1] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 1 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP2] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 2 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP3] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 3 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP4] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 4 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP5] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 5 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP6] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 6 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP7] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 7 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP8] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 8 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP9] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 9 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP10] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 10 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationISP11] = D.ISP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 11 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP1] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 1 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP2] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 2 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP3] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 3 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP4] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 4 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP5] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 5 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP6] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 6 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP7] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 7 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP8] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 8 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP9] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 9 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP10] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 10 and D.[Year] <= PBDT.[PostSale Term]
update PBDT set [DepreciationOSP11] = D.OSP from ProjApproval.Compute_PostSale_BDT as PBDT, ProjApproval.DepreciationSchedule AS D where D.[Year] = 11 and D.[Year] <= PBDT.[PostSale Term]
--------------------------------------------------------------------------------------------------
--Trim depreciation data

update ProjApproval.Compute_PostSale_BDT set DepreciationISP1 = 0 where DepreciationISP1 is null or [PostSale Term] < 1
update ProjApproval.Compute_PostSale_BDT set DepreciationISP2 = 0 where DepreciationISP2 is null or [PostSale Term] < 2
update ProjApproval.Compute_PostSale_BDT set DepreciationISP3 = 0 where DepreciationISP3 is null or [PostSale Term] < 3
update ProjApproval.Compute_PostSale_BDT set DepreciationISP4 = 0 where DepreciationISP4 is null or [PostSale Term] < 4
update ProjApproval.Compute_PostSale_BDT set DepreciationISP5 = 0 where DepreciationISP5 is null or [PostSale Term] < 5
update ProjApproval.Compute_PostSale_BDT set DepreciationISP6 = 0 where DepreciationISP6 is null or [PostSale Term] < 6
update ProjApproval.Compute_PostSale_BDT set DepreciationISP7 = 0 where DepreciationISP7 is null or [PostSale Term] < 7
update ProjApproval.Compute_PostSale_BDT set DepreciationISP8 = 0 where DepreciationISP8 is null or [PostSale Term] < 8
update ProjApproval.Compute_PostSale_BDT set DepreciationISP9 = 0 where DepreciationISP9 is null or [PostSale Term] < 9
update ProjApproval.Compute_PostSale_BDT set DepreciationISP10 = 0 where DepreciationISP10 is null or [PostSale Term] < 10
update ProjApproval.Compute_PostSale_BDT set DepreciationISP11 = 0 where DepreciationISP11 is null or [PostSale Term] < 11
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP1 = 0 where DepreciationOSP1 is null or [PostSale Term] < 1
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP2 = 0 where DepreciationOSP2 is null or [PostSale Term] < 2
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP3 = 0 where DepreciationOSP3 is null or [PostSale Term] < 3
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP4 = 0 where DepreciationOSP4 is null or [PostSale Term] < 4
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP5 = 0 where DepreciationOSP5 is null or [PostSale Term] < 5
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP6 = 0 where DepreciationOSP6 is null or [PostSale Term] < 6
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP7 = 0 where DepreciationOSP7 is null or [PostSale Term] < 7
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP8 = 0 where DepreciationOSP8 is null or [PostSale Term] < 8
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP9 = 0 where DepreciationOSP9 is null or [PostSale Term] < 9
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP10 = 0 where DepreciationOSP10 is null or [PostSale Term] < 10
update ProjApproval.Compute_PostSale_BDT set DepreciationOSP11 = 0 where DepreciationOSP11 is null or [PostSale Term] < 11

------------------------------------------------------------------------------------------
--Trim Capital data

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale ISP Capital] = 0
WHERE [PostSale ISP Capital] IS NULL

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale OSP Capital] = 0
WHERE [PostSale OSP Capital] IS NULL

update [ProjApproval].[Compute_PostSale_BDT]
set [PostSale Total Capital] = 0
WHERE [PostSale Total Capital] IS NULL

---------------------------------------------------------------------------------------------------
--Computing depreciation $
declare @t Table (OppID [varchar] (50), NewYrHalf money, OldYrHalf money)
--Year 1 ISP Dep
UPDATE ProjApproval.Compute_PostSale_BDT 
SET [DepreciationISP1] = (([PostSale ISP Capital] - CIAC_ISP)*DepreciationISP1)/2 
where [PostSale Term] >=  1

--Year 2 ISP Dep
INSERT INTO @t (OppID,OldYrHalf)  
select [Opportunity ID],[DepreciationISP1] 
from ProjApproval.Compute_PostSale_BDT 
UPDATE @t
SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP2])/2
FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT
WHERE [@t].OppID = PBDT.[Opportunity ID]
UPDATE PBDT   
SET [DepreciationISP2]=NewYrHalf+OldYrHalf
from ProjApproval.Compute_PostSale_BDT AS PBDT, @t 
where PBDT.[PostSale Term] >= 2 AND [@t].OppID = PBDT.[Opportunity ID]

----year 3 and onwards ISP Dep

update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP3])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP3]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 3 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP4])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP4]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 4 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP5])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP5]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 5 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP6])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP6]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 6 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP7])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP7]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 7 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP8])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP8]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 8 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP9])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP9]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 9 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP10])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP10]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 10 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale ISP Capital]-CIAC_ISP)*[DepreciationISP11])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationISP11]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 11 AND [@t].OppID = PBDT.[Opportunity ID]

--Year 1 OSP Dep
UPDATE ProjApproval.Compute_PostSale_BDT 
SET [DepreciationOSP1] = (([PostSale OSP Capital] - CIAC_OSP)*DepreciationOSP1)/2 
where [PostSale Term] >=  1

--Year 2 OSP Dep
DELETE FROM @t
INSERT INTO @t (OppID,OldYrHalf)  
select [Opportunity ID],[DepreciationOSP1] 
from ProjApproval.Compute_PostSale_BDT 
UPDATE @t
SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP2])/2
FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT
WHERE [@t].OppID = PBDT.[Opportunity ID]
UPDATE PBDT   
SET [DepreciationOSP2]=NewYrHalf+OldYrHalf
from ProjApproval.Compute_PostSale_BDT AS PBDT, @t 
where PBDT.[PostSale Term] >= 2 AND [@t].OppID = PBDT.[Opportunity ID]

--year 3 and onwards OSP Dep

update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP3])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP3]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 3 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP4])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP4]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 4 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP5])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP5]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 5 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP6])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP6]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 6 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP7])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP7]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 7 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP8])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP8]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 8 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP9])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP9]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 9 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP10])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP10]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 10 AND [@t].OppID = PBDT.[Opportunity ID]
update @t set OldYrHalf = NewYrHalf UPDATE @t SET NewYrHalf = (([PostSale OSP Capital]-CIAC_OSP)*[DepreciationOSP11])/2 FROM @t, ProjApproval.Compute_PostSale_BDT as PBDT WHERE [@t].OppID = PBDT.[Opportunity ID] UPDATE PBDT    SET [DepreciationOSP11]=NewYrHalf+OldYrHalf from ProjApproval.Compute_PostSale_BDT AS PBDT, @t  where PBDT.[PostSale Term] >= 11 AND [@t].OppID = PBDT.[Opportunity ID]

--Zero out -ve depreciation
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP1]=0 where [DepreciationISP1]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP2]=0 where [DepreciationISP2]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP3]=0 where [DepreciationISP3]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP4]=0 where [DepreciationISP4]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP5]=0 where [DepreciationISP5]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP6]=0 where [DepreciationISP6]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP7]=0 where [DepreciationISP7]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP8]=0 where [DepreciationISP8]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP9]=0 where [DepreciationISP9]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP10]=0 where [DepreciationISP10]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationISP11]=0 where [DepreciationISP11]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP1]=0 where [DepreciationOSP1]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP2]=0 where [DepreciationOSP2]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP3]=0 where [DepreciationOSP3]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP4]=0 where [DepreciationOSP4]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP5]=0 where [DepreciationOSP5]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP6]=0 where [DepreciationOSP6]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP7]=0 where [DepreciationOSP7]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP8]=0 where [DepreciationOSP8]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP9]=0 where [DepreciationOSP9]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP10]=0 where [DepreciationOSP10]<0
UPDATE ProjApproval.Compute_PostSale_BDT SET [DepreciationOSP11]=0 where [DepreciationOSP11]<0


----test
--select OppId, NewYrHalf, OldYrHalf from @t

----------------------------------------------------------------------------------------------------
--Compute tax
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX1 = ([PostSale MRC] * 12 + [PostSale NRC] - DepreciationISP1 - DepreciationOSP1) * TaxRate
where [PostSale Term] >=  1
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX2 = ([PostSale MRC] * 12 - DepreciationISP2 - DepreciationOSP2) * TaxRate
where [PostSale Term] >=  2
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX3 = ([PostSale MRC] * 12 - DepreciationISP3 - DepreciationOSP3) * TaxRate
where [PostSale Term] >=  3
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX4 = ([PostSale MRC] * 12 - DepreciationISP4 - DepreciationOSP4) * TaxRate
where [PostSale Term] >=  4
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX5 = ([PostSale MRC] * 12 - DepreciationISP5 - DepreciationOSP5) * TaxRate
where [PostSale Term] >=  5
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX6 = ([PostSale MRC] * 12 - DepreciationISP6 - DepreciationOSP6) * TaxRate
where [PostSale Term] >=  6
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX7 = ([PostSale MRC] * 12 - DepreciationISP7 - DepreciationOSP7) * TaxRate
where [PostSale Term] >=  7
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX8 = ([PostSale MRC] * 12 - DepreciationISP8 - DepreciationOSP8) * TaxRate
where [PostSale Term] >=  8
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX9 = ([PostSale MRC] * 12 - DepreciationISP9 - DepreciationOSP9) * TaxRate
where [PostSale Term] >=  9
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX10 = ([PostSale MRC] * 12 - DepreciationISP10 - DepreciationOSP10) * TaxRate
where [PostSale Term] >=  10
UPDATE ProjApproval.Compute_PostSale_BDT
SET TAX11 = ([PostSale MRC] * 12 - DepreciationISP11 - DepreciationOSP11) * TaxRate
where [PostSale Term] >=  11

--------------------------------------------------------------------------------------------------
--Set discount rate
update ProjApproval.Compute_PostSale_BDT
set DiscountRate = 0.15
--------------------------------------------------------------------------------------------------
--Trim tax
update ProjApproval.Compute_PostSale_BDT
set TAX1 = 0 where Tax1 is null OR [PostSale Term] < 1
update ProjApproval.Compute_PostSale_BDT
set TAX2 = 0 where Tax2 is null OR [PostSale Term] < 2
update ProjApproval.Compute_PostSale_BDT
set TAX3 = 0 where Tax3 is null OR [PostSale Term] < 3
update ProjApproval.Compute_PostSale_BDT
set TAX4 = 0 where Tax4 is null OR [PostSale Term] < 4
update ProjApproval.Compute_PostSale_BDT
set TAX5 = 0 where Tax5 is null OR [PostSale Term] < 5
update ProjApproval.Compute_PostSale_BDT
set TAX6 = 0 where Tax6 is null OR [PostSale Term] < 6
update ProjApproval.Compute_PostSale_BDT
set TAX7 = 0 where Tax7 is null OR [PostSale Term] < 7
update ProjApproval.Compute_PostSale_BDT
set TAX8 = 0 where Tax8 is null OR [PostSale Term] < 8
update ProjApproval.Compute_PostSale_BDT
set TAX9 = 0 where Tax9 is null OR [PostSale Term] < 9
update ProjApproval.Compute_PostSale_BDT
set TAX10 = 0 where Tax10 is null OR [PostSale Term] < 10
update ProjApproval.Compute_PostSale_BDT
set TAX11 = 0 where Tax11 is null OR [PostSale Term] < 11
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
INSERT INTO @CF (OppID) select [Opportunity ID] from ProjApproval.Compute_PostSale_BDT
update @CF
set CF0 = -([PostSale Total Capital] - [Common Capital] - [PostSale CIAC])
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]

update @CF
set CF1 = (([PostSale MRC]*12.0 + [PostSale NRC] - Tax1)/(Power(1.0+DiscountRate, 1.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax1 != 0

update @CF
set CF2 = (([PostSale MRC]*12.0 - Tax2)/(Power(1.0+DiscountRate, 2.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax2 != 0

update @CF
set CF3 = (([PostSale MRC]*12.0 - Tax3)/(Power(1.0+DiscountRate, 3.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax3 != 0

update @CF
set CF4 = (([PostSale MRC]*12.0 - Tax4)/(Power(1.0+DiscountRate, 4.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax4 != 0

update @CF
set CF5 = (([PostSale MRC]*12.0 - Tax5)/(Power(1.0+DiscountRate, 5.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax5 != 0

update @CF
set CF6 = (([PostSale MRC]*12.0 - Tax6)/(Power(1.0+DiscountRate, 6.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax6 != 0

update @CF
set CF7 = (([PostSale MRC]*12.0 - Tax7)/(Power(1.0+DiscountRate, 7.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax7 != 0

update @CF
set CF8 = (([PostSale MRC]*12.0 - Tax8)/(Power(1.0+DiscountRate, 8.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax8 != 0

update @CF
set CF9 = (([PostSale MRC]*12.0 - Tax9)/(Power(1.0+DiscountRate, 9.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax9 != 0

update @CF
set CF10 = (([PostSale MRC]*12.0 - Tax10)/(Power(1.0+DiscountRate, 10.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax10 != 0

update @CF
set CF11 = (([PostSale MRC]*12.0 - Tax11)/(Power(1.0+DiscountRate, 11.0)))
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax11 != 0


--Get NPV for each valid year
update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 1

update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1+CF2
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 2

update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1+CF2+CF3
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 3

update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1+CF2+CF3+CF4
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 4

update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 5

update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 6

update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 7

update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 8

update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8+CF9
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 9

update ProjApproval.Compute_PostSale_BDT
set [PostSale NPV] = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8+CF9+CF10
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] = 10

--Bring NPV to history trimmed table for each opportunity
update HBDT
set [PostSale NPV] = PBDT.[PostSale NPV]
from ProjApproval.Compare_BDT_History_Trimmed as HBDT,
ProjApproval.Compute_PostSale_BDT as PBDT
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
set CF0 = -([PostSale Total Capital] - [Common Capital] - [PostSale CIAC])
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]

update @CF
set CF1 = [PostSale MRC]*12.0 + [PostSale NRC] - Tax1
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax1 != 0

update @CF
set CF2 = [PostSale MRC]*12.0 - Tax2
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax2 != 0

update @CF
set CF3 = [PostSale MRC]*12.0 - Tax3
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax3 != 0

update @CF
set CF4 = [PostSale MRC]*12.0 - Tax4
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax4 != 0

update @CF
set CF5 = [PostSale MRC]*12.0 - Tax5
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax5 != 0

update @CF
set CF6 = [PostSale MRC]*12.0 - Tax6
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax6 != 0

update @CF
set CF7 = [PostSale MRC]*12.0 - Tax7
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax7 != 0

update @CF
set CF8 = [PostSale MRC]*12.0 - Tax8
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax8 != 0

update @CF
set CF9 = [PostSale MRC]*12.0 - Tax9
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax9 != 0

update @CF
set CF10 = [PostSale MRC]*12.0 - Tax10
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax10 != 0

update @CF
set CF11 = [PostSale MRC]*12.0 - Tax11
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.Tax11 != 0

--Copy cash flow to history trimmed table
UPDATE HBDT
set [Post_C0] = [@CF].[CF0]
, [Post_C1] = [@CF].[CF1]
, [Post_C2] = [@CF].[CF2]
, [Post_C3] = [@CF].[CF3]
, [Post_C4] = [@CF].[CF4]
, [Post_C5] = [@CF].[CF5]
, [Post_C6] = [@CF].[CF6]
, [Post_C7] = [@CF].[CF7]
, [Post_C8] = [@CF].[CF8]
, [Post_C9] = [@CF].[CF9]
, [Post_C10] = [@CF].[CF10]
, [Post_C11] = [@CF].[CF11]
from ProjApproval.Compare_BDT_History_Trimmed AS HBDT, @CF
WHERE HBDT.[Opportunity ID] = [@CF].OppID


-----------------------------------------------------------------------------------
----Payback https://xplaind.com/849768/payback-period


--Get cummulative cash flows for each valid year
update ProjApproval.Compute_PostSale_BDT
set CC0 = CF0
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 0

update ProjApproval.Compute_PostSale_BDT
set CC1 = CF0+CF1
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 1

update ProjApproval.Compute_PostSale_BDT
set CC2 = CF0+CF1+CF2
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 2

update ProjApproval.Compute_PostSale_BDT
set CC3 = CF0+CF1+CF2+CF3
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 3

update ProjApproval.Compute_PostSale_BDT
set CC4 = CF0+CF1+CF2+CF3+CF4
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 4

update ProjApproval.Compute_PostSale_BDT
set CC5 = CF0+CF1+CF2+CF3+CF4+CF5
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 5

update ProjApproval.Compute_PostSale_BDT
set CC6 = CF0+CF1+CF2+CF3+CF4+CF5+CF6
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 6

update ProjApproval.Compute_PostSale_BDT
set CC7 = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 7

update ProjApproval.Compute_PostSale_BDT
set CC8 = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 8

update ProjApproval.Compute_PostSale_BDT
set CC9 = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8+CF9
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 9

update ProjApproval.Compute_PostSale_BDT
set CC10 = CF0+CF1+CF2+CF3+CF4+CF5+CF6+CF7+CF8+CF9+CF10
from @CF, ProjApproval.Compute_PostSale_BDT as PBDT
where [@CF].OppID = PBDT.[Opportunity ID]
and PBDT.[PostSale Term] >= 10

update ProjApproval.Compute_PostSale_BDT set CC1=0 WHERE CC1=CC0
update ProjApproval.Compute_PostSale_BDT set CC2=0 WHERE CC2=CC1 OR CC2=CC1 OR CC2=CC0
update ProjApproval.Compute_PostSale_BDT set CC3=0 WHERE CC3=CC2 OR CC3=CC1 OR CC3=CC0
update ProjApproval.Compute_PostSale_BDT set CC4=0 WHERE CC4=CC3 OR CC4=CC2 OR CC4=CC1 OR CC4=CC0
update ProjApproval.Compute_PostSale_BDT set CC5=0 WHERE CC5=CC4 OR CC5=CC3 OR CC5=CC2 OR CC5=CC1 OR CC5=CC0
update ProjApproval.Compute_PostSale_BDT set CC6=0 WHERE CC6=CC5 OR CC6=CC4 OR CC6=CC3 OR CC6=CC2 OR CC6=CC1 OR CC6=CC0
update ProjApproval.Compute_PostSale_BDT set CC7=0 WHERE CC7=CC6 OR CC7=CC5 OR CC7=CC4 OR CC7=CC3 OR CC7=CC2 OR CC7=CC1 OR CC7=CC0
update ProjApproval.Compute_PostSale_BDT set CC8=0 WHERE CC8=CC7 OR CC8=CC6 OR CC8=CC5 OR CC8=CC4 OR CC8=CC3 OR CC8=CC2 OR CC8=CC1 OR CC8=CC0
update ProjApproval.Compute_PostSale_BDT set CC9=0 WHERE CC9=CC8 OR CC9=CC7 OR CC9=CC6 OR CC9=CC5 OR CC9=CC4 OR CC9=CC3 OR CC9=CC2 OR CC9=CC1 OR CC9=CC0
update ProjApproval.Compute_PostSale_BDT set CC10=0 WHERE CC10=CC9 OR CC10=CC8 OR CC10=CC7 OR CC10=CC6 OR CC10=CC5 OR CC10=CC4 OR CC10=CC3 OR CC10=CC2 OR CC10=CC1 OR CC10=CC0
update ProjApproval.Compute_PostSale_BDT set CC11=0 WHERE CC11=CC10 OR CC11=CC9 OR CC11=CC8 OR CC11=CC7 OR CC11=CC6 OR CC11=CC5 OR CC11=CC4 OR CC11=CC3 OR CC11=CC2 OR CC11=CC1 OR CC11=CC0

--Copy cumulative cashflows into PostSale history table
update HBDT
set HBDT.Post_CC0 = PBDT.CC0
,HBDT.Post_CC1 = PBDT.CC1
,HBDT.Post_CC2 = PBDT.CC2
,HBDT.Post_CC3 = PBDT.CC3
,HBDT.Post_CC4 = PBDT.CC4
,HBDT.Post_CC5 = PBDT.CC5
,HBDT.Post_CC6 = PBDT.CC6
,HBDT.Post_CC7 = PBDT.CC7
,HBDT.Post_CC8 = PBDT.CC8
,HBDT.Post_CC9 = PBDT.CC9
,HBDT.Post_CC10 = PBDT.CC10
,HBDT.Post_CC11 = PBDT.CC11
from ProjApproval.Compare_BDT_History_Trimmed as HBDT,
ProjApproval.Compute_PostSale_BDT as PBDT
where HBDT.[Opportunity ID] = PBDT.[Opportunity ID]

--Trim cummulative cash flow data in history table
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC0=0 where CC0 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC1=0 where CC1 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC2=0 where CC2 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC3=0 where CC3 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC4=0 where CC4 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC5=0 where CC5 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC6=0 where CC6 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC7=0 where CC7 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC8=0 where CC8 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC9=0 where CC9 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC10=0 where CC10 is null
update ProjApproval.Compare_BDT_History_Trimmed set Post_CC11=0 where CC11 is null


--Get individual payback for each year
update ProjApproval.Compute_PostSale_BDT set P0=0+(1-CC1/(CC1-CC0)) where CC0<0 and CC1>0
update ProjApproval.Compute_PostSale_BDT set P1=1+(1-CC2/(CC2-CC1)) where CC1<0 and CC2>0
update ProjApproval.Compute_PostSale_BDT set P2=2+(1-CC3/(CC3-CC2)) where CC2<0 and CC3>0
update ProjApproval.Compute_PostSale_BDT set P3=3+(1-CC4/(CC4-CC3)) where CC3<0 and CC4>0
update ProjApproval.Compute_PostSale_BDT set P4=4+(1-CC5/(CC5-CC4)) where CC4<0 and CC5>0
update ProjApproval.Compute_PostSale_BDT set P5=5+(1-CC6/(CC6-CC5)) where CC5<0 and CC6>0
update ProjApproval.Compute_PostSale_BDT set P6=6+(1-CC7/(CC7-CC6)) where CC6<0 and CC7>0
update ProjApproval.Compute_PostSale_BDT set P7=7+(1-CC8/(CC8-CC7)) where CC7<0 and CC8>0
update ProjApproval.Compute_PostSale_BDT set P8=8+(1-CC9/(CC9-CC8)) where CC8<0 and CC9>0
update ProjApproval.Compute_PostSale_BDT set P9=9+(1-CC10/(CC10-CC9)) where CC9<0 and CC10>0
update ProjApproval.Compute_PostSale_BDT set P10=10+(1-CC11/(CC11-CC10)) where CC10<0 and CC11>0

--Trim individual payback data for each year
update ProjApproval.Compute_PostSale_BDT set P0=0 WHERE P0 IS NULL
update ProjApproval.Compute_PostSale_BDT set P1=0 WHERE P1 IS NULL
update ProjApproval.Compute_PostSale_BDT set P2=0 WHERE P2 IS NULL
update ProjApproval.Compute_PostSale_BDT set P3=0 WHERE P3 IS NULL
update ProjApproval.Compute_PostSale_BDT set P4=0 WHERE P4 IS NULL
update ProjApproval.Compute_PostSale_BDT set P5=0 WHERE P5 IS NULL
update ProjApproval.Compute_PostSale_BDT set P6=0 WHERE P6 IS NULL
update ProjApproval.Compute_PostSale_BDT set P7=0 WHERE P7 IS NULL
update ProjApproval.Compute_PostSale_BDT set P8=0 WHERE P8 IS NULL
update ProjApproval.Compute_PostSale_BDT set P9=0 WHERE P9 IS NULL
update ProjApproval.Compute_PostSale_BDT set P10=0 WHERE P10 IS NULL
update ProjApproval.Compute_PostSale_BDT set P11=0 WHERE P11 IS NULL

--Final payback
update ProjApproval.Compute_PostSale_BDT 
set [PostSale PAYBACK] = P0+P1+P2+P3+P4+P5+P6+P7+P8+P9+P10

update ProjApproval.Compute_PostSale_BDT 
set [PostSale PAYBACK] = 0
where [PostSale PAYBACK] < 0

--Copy payback and capital data to original table
update HBDT
set [PostSale PAYBACK] = PBDT.[PostSale PAYBACK]
,[PostSale ISP Capital] = PBDT.[PostSale ISP Capital]
,[PostSale OSP Capital] = PBDT.[PostSale OSP Capital]
,[PostSale Total Capital] = PBDT.[PostSale Total Capital]
from ProjApproval.Compare_BDT_History_Trimmed as HBDT,
ProjApproval.Compute_PostSale_BDT as PBDT
where HBDT.[Opportunity ID] = PBDT.[Opportunity ID]

UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_FTTH__usp_Compute_PostSale_BDT P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_FTTH__usp_Compute_PostSale_BDT

--------------------------------------------------------------------

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
