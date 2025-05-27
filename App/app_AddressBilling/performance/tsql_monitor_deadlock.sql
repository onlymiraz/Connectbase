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

