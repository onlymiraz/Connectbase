USE [Playground];
GO

DELETE lz
OUTPUT
  DELETED.[user_def_row_ID],
  DELETED.[Address1],
  DELETED.[Address2],
  DELETED.[City],
  DELETED.[Zip],
  DELETED.[State],
  DELETED.[Country],
  DELETED.[DtmStamp],
  DELETED.[ingestion_timestamp],
  DELETED.[user_name],
  DELETED.[user_corp],
  DELETED.[batch_id],
  DELETED.[user_email],
  DELETED.[process_status]
INTO [addressbilling].[UI_LZ_Archive] (
  [user_def_row_ID],
  [Address1],
  [Address2],
  [City],
  [Zip],
  [State],
  [Country],
  [DtmStamp],
  [ingestion_timestamp],
  [user_name],
  [user_corp],
  [batch_id],
  [user_email],
  [process_status]
)
FROM [addressbilling].[UI_LZ] lz
WHERE lz.process_status = 'done';

PRINT 'UI_LZ done rows archived and removed.';
GO
