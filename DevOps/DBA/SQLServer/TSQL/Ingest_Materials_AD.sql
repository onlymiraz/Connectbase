USE MaterialsStaging
--CREATE SCHEMA data_ingest

/*
CREATE TABLE data_ingest.materials_user_AD (
Corp_ID nvarchar(10) NOT NULL,
Display_Name nvarchar(50) NULL,
Employer nvarchar(100) NULL,
WarehouseCode_1 nvarchar(10) NULL,
WarehouseCode_2 nvarchar(10) NULL,
WarehouseCode_3 nvarchar(10) NULL,
WarehouseCode_4 nvarchar(10) NULL,
WarehouseState_1 nvarchar(5) NULL,
Manager_First_Name nvarchar(15) NULL,
Manager_Last_Name nvarchar(20) NULL,
Manager_Corp nvarchar(10) NULL,
Job_Title nvarchar(100) NULL,
Email nvarchar(100) NULL,
Address_State nvarchar(5) NULL,
Department nvarchar(50) NULL,
Proposed_AD nvarchar(25) NULL,
Employment_Type nvarchar(5) NULL,
PhoneNumber nvarchar(50) NULL,
Access_ticket_number nvarchar(25) NULL
)
*/


/*
BULK INSERT data_ingest.materials_user_AD
FROM 'D:\DataDump\Back-end\data_ingest__materials_user_AD.TXT'
WITH (FIRSTROW=2)


UPDATE [data_ingest].[materials_user_AD]
SET Display_Name=REPLACE(Display_Name,'"','')
,Employer=REPLACE(Employer,'"','')
,Job_Title=REPLACE(Job_Title,'"','')
*/



--SELECT max(len(Manager_Corp+Manager_First_Name+Manager_Last_Name)) FROM [data_ingest].[materials_user_AD]



/*

UPDATE [data_ingest].[materials_user_AD] 
SET Proposed_AD='Construction'
WHERE Proposed_AD='Contruction'

UPDATE AD
SET Comments=DI.Access_ticket_number
FROM [FTTH].[BulkReelUsage_UserAD] AD
INNER JOIN [data_ingest].[materials_user_AD] DI
ON AD.[Corp ID]=DI.Corp_ID
WHERE Comments NOT LIKE '%REQ%'

UPDATE AD
SET WarehouseCode1=DI.WarehouseCode_1
FROM [FTTH].[BulkReelUsage_UserAD] AD
INNER JOIN [data_ingest].[materials_user_AD] DI
ON AD.[Corp ID]=DI.Corp_ID
WHERE DI.WarehouseCode_1 NOT LIKE '%ALL%'
AND DI.WarehouseCode_1 NOT LIKE '%all%'
AND DI.WarehouseCode_1 NOT LIKE '%Change%'


UPDATE AD
SET WarehouseCode2=DI.WarehouseCode_2
,WarehouseCode3=DI.WarehouseCode_3
,WarehouseCode4=DI.WarehouseCode_4
,State1=DI.WarehouseState_1
,Manager=DI.Manager_First_Name+' '+Manager_Last_Name+' '+Manager_Corp
,FullName=DI.Display_Name
,Employer=DI.Employer
,Title=DI.Job_Title
,Email=DI.Email
,Address_State=DI.Address_State
,Phone_Work=DI.PhoneNumber
FROM [FTTH].[BulkReelUsage_UserAD] AD
INNER JOIN [data_ingest].[materials_user_AD] DI
ON AD.[Corp ID]=DI.Corp_ID


UPDATE [FTTH].[BulkReelUsage_UserAD]
SET Email=REPLACE(Email,' ','')
,[Corp ID]=REPLACE([Corp ID],' ','')


DELETE FROM [FTTH].[BulkReelUsage_UserAD]
WHERE [Corp ID] IN ('nhh007',
'amm3194',
'arr835',
'bpp989',
'drr518',
'rrr903',
'cwa500',
'ycc487',
'tww310',
'jmo920',
'acc718',
'ess309',
'slc353',
'aww404',
'rkk637',
'joo988',
'jmm2214',
'jpp883',
'hbb046',
'imm551',
'pgg273',
'jcc1232',
'sbb297',
'joo230',
'noo970',
'rpp481',
'wss510',
'dbb821',
'kss349',
'sww635',
'jcc1256',
'rjj326',
'jbb9951',
'ktt342',
'rll6601',
'kff814',
'jdd711',
'cxc841',
'rcc385',
'jff226',
'jww540',
'blb017',
'jjh215',
'tgm394',
'cjj683',
'jrr164',
'gmg098 ',
' jhh345',
' jee403',
'mee707',
'arr946',
'rbb338',
' jjb3515',
'rss519',
'baa235',
'ajb578',
'v_tff234',
'rbb283',
'tbb656',
'jrr133',
'bcc612',
'chh513',
'mjj650',
'mgg136',
'dhh705',
'epp499',
'bmm645',
'aoo760',
'rtt512',
'rhh153',
'tff282',
'tss702',
'dkk107',
'dyy387',
'mrs381',
'spp813',
'mdd757',
'dbb083',
'jpp260',
'rdd825',
'aah453')



*/