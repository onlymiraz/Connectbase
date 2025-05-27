--deadlock
SELECT
  r.session_id,
  r.blocking_session_id,
  r.wait_type,
  r.wait_time,
  DB_NAME(r.database_id) AS database_name,
  t.text AS sql_text,
  s.login_name,
  s.host_name,
  s.program_name
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id != @@SPID  -- exclude current session
ORDER BY r.session_id;
--KILL 113
 
 
use [Playground]
SELECT count(*) ct_rawUserData fROM [addressbilling].[UI_LZ] --not done yet
SELECT count(*) ct_fuzzymatch_doing FROM [addressbilling].[Fuzzymatch_Output] --doing
SELECT count(*) ct_fuzzymatch_done FROM [addressbilling].[Fuzzymatch_Output_Archive] --done (with match)
SELECT count(*) ct_rawUserDataArchived FROM [addressbilling].[UI_LZ_Archive] -- done (users's raw data)


/*
QAT
1. Check results
2. Check timing/duration
3. Order of operation
4. Orchestration
5. Email confirmation (1 for initial upload, and 1 for completion of fuzzymatch)
6. Databricks (Teradata decom; flask hosting)


*/