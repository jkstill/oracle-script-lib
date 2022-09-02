
-- Jared Still - 2022
-- jkstill@gmail.com


set linesize 250 trimspool on
set pagesize 100

col owner format a15
col directory_name format a30
col directory_path format a100
col oreated format a19
col last_ddl_time format a19

select
	d.owner
	, d.directory_name
	, to_char(o.created,'yyyy-mm-dd hh24:mi:ss') oreated
	, to_char(o.last_ddl_time,'yyyy-mm-dd hh24:mi:ss') last_ddl_time
	, d.directory_path
from dba_directories d
join dba_objects o on o.owner = d.owner and o.object_name = d.directory_name
order by 1,2
/
