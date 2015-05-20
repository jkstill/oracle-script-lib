
-- dba_dependencies.sql
-- jkstill@gmail.com
-- base query from Jacques Kilchoer
-- 11/07/2006 - jkstill - added no_merge hints
--   encapsulated into inline view
--   added 'level'
--   display child DDL time
--
-- call on the command line:
--   @dba_dependencies <OWNER> <OBJECT>
-- if not on the command line, user will be
-- prompted for values


@clears
@columns

prompt Dependencies for Owner?:

col cowner noprint new_value uowner
set term off feed off
select upper('&1') cowner from dual;
set term on feed on

prompt Dependencies for Object?:

col cobject noprint new_value uobject
set term off feed off
select upper('&2') cobject from dual;
set term on feed on

set line 142 pages 60

column display_parent format a58
column display_child format a58
column referenced_owner noprint
column referenced_object noprint
column referenced_type noprint
column owner noprint
column object noprint
column type noprint
column last_ddl_time format a22 head 'CHILD DDL TIME'

undef 1 2

with dependencies as (
	-- top down through the heirarchy
	select /*+ no_merge */
		referenced_type || ' "' || referenced_owner || '"."' ||
		referenced_name || '"' as parent,
		type || ' "' || owner || '"."' || name || '"' as child,
		level hlevel,
		referenced_owner, referenced_name, referenced_type,
		owner, name, type
	from dba_dependencies
	start with
		referenced_owner = '&&uowner'
		and referenced_name = '&&uobject'
	connect by
		referenced_owner = prior owner
		and referenced_name = prior name
		and referenced_type = prior type
	union
	-- bottom up through the heirarchy
	select /*+ no_merge */
		referenced_type || ' "' || referenced_owner || '"."' ||
		referenced_name || '"' as parent,
		type || ' "' || owner || '"."' || name || '"' as child,
		level hlevel,
		referenced_owner, referenced_name, referenced_type,
		owner, name, type
	from dba_dependencies
	start with
		owner = '&&uowner'
		and name = '&&uobject'
	connect by
		owner = prior referenced_owner
		and name = prior referenced_name
		and type = prior referenced_type
	order by 1, 2
)
select lpad(' ',2*d.hlevel,' ') || d.parent display_parent, d.child display_child, o.last_ddl_time 
from dependencies d, dba_objects o
where o.owner = d.owner
and o.object_type = d.type
and d.name = o.object_name
order by parent, child
/


