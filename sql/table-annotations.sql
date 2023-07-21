
-- table-annotations.sql
-- show any tables that have had result_cache set to FORCE or MANUAL
-- (and possibly other values in the future)

set linesize 200 trimspool on
set tab off
set pagesize 100

col table_name format a30
col result_cache format a10 head 'RESULT|CACHE'
col timestamp format a19
col created format a19
col last_ddl_time format a19
col owner format a15

select t.owner, t.table_name, t.result_cache
	, to_char(o.created,'yyyy-mm-dd hh24:mi:ss') created
	, to_char(o.last_ddl_time,'yyyy-mm-dd hh24:mi:ss') last_ddl_time
	, o.timestamp
from dba_tables t
	join dba_objects o on o.owner = t.owner
		and o.object_name = t.table_name
		and o.object_type = 'TABLE'
where t.result_cache != 'DEFAULT'
order by t.owner, t.table_name
/
