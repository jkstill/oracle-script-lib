
-- findobj.sql
-- 08/07/2000 - jks - join on v$fixed_table


@clears
set pagesize 60
set linesize 200

col cobject noprint new_value uobject

prompt Find object name like? :
set term off feed off
select upper('&1') cobject from dual;
set term on feed on

col object_name format a30
col owner format a10
col created format a21
col last_ddl_time format a21


select object_name
	,object_type
	, owner
	, status
	, to_char(created,'mm/dd/yyyy hh24:mi:ss') created
	, to_char(last_ddl_time,'mm/dd/yyyy hh24:mi:ss') last_ddl_time
from dba_objects
where object_name like upper('%&&uobject%')
union all
select name object_name, type object_type, 'SYS' owner, 'FIXED' status, null created, null last_ddl_time
from v$fixed_table
where name like upper('%&&uobject%')
order by object_name
/

undef 1

