CREATE EVENT SESSION [UniqueCaptureLogins] ON SERVER 
ADD EVENT [sqlserver].[login]
    (
    ACTION ([sqlserver].[sql_text],
            [sqlserver].[username],
            [sqlserver].[client_hostname])
    WHERE ([sqlserver].[username]<>N'sa' AND [sqlserver].[username]<>N'NT AUTHORITY\SYSTEM')
    ) 
ADD TARGET [package0].[event_file]
    (
    SET filename = 'C:\Users\mmm722\Downloads\UniqueCaptureLogins.xel',
        metadatafile = 'C:\Users\mmm722\Downloads\UniqueCaptureLogins.xem'
    )
WITH  (
        MAX_MEMORY = 4 MB,
        EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
        MAX_DISPATCH_LATENCY = 30 SECONDS,
        MEMORY_PARTITION_MODE = NONE,
        TRACK_CAUSALITY = OFF,
        STARTUP_STATE = OFF
      );

