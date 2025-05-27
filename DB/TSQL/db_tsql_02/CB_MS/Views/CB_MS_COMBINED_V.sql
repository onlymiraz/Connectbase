CREATE VIEW CB_MS.[CB_MS_COMBINED_V] AS



select [ID]
      ,[LOGIN_ID]
      ,[ROUTE_NAME]
      ,[REQUESTING_COMPANY]
      ,[CLIENT_COMPANY]
      ,[CCNA_X]
      ,[ADDRESS]
      ,[CITY]
      ,[STATE]
      ,[ZIP]
      ,[COUNTY]
      ,[COUNTRY]
      ,[USER_COMPANY]
      ,[TARGET_COMPANY_ID]
      ,[TARGET_COMPANY]
      ,[REQUEST_DATE]
      ,[RESULT]
      ,[SERVICENAME]
      ,[SERVICE_TYPE]
      ,[ERROR_MESSAGE]
      ,[TERMS]
      ,[FILE_NAME]
      ,[UPDATED_DT]
from(
select a.*
,row_number() over(partition by ID order by UPDATED_DT desc) as row_num

 FROM CB_MS.TBL_CB_MS_COMBINED A



)a

where row_num = 1

