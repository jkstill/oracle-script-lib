
-- gather-db-system-stats.sql
-- gather non-user object stats
-- 

prompt
prompt Gather Dictionary Stats
prompt
exec dbms_stats.gather_dictionary_stats

prompt
prompt Gather Fixed Objects Stats
prompt
exec dbms_stats.gather_fixed_objects_stats

prompt
prompt Gather Sys Schema Stats
prompt
exec dbms_stats.gather_schema_stats('SYS')

