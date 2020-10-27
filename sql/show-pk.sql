
-- show-pk.sql - show primary key constraints


@clears

col cuser noprint new_value uuser
prompt PK Columns for which account?:
set term off feed off
select upper('&1') cuser from dual;
set term on feed on

col table_name format a30
col constraintname format a30
col columnname format a30
col pos format 999

set pagesize 100
set linesize 200 trimspool on

set echo off

break on table_name skip 1 on constraintname skip 1

select
	a.table_name
	, a.constraint_name constraintname
	, b.column_name columnname
	, b.position pos
from dba_constraints a
	, dba_cons_columns b
where a.owner = '&uuser'
and a.constraint_type = 'P'
and a.table_name = b.table_name
and a.constraint_name = b.constraint_name
and a.owner = b.owner
order by
	a.table_name
	,a.constraint_name
	, b.position
/

undef 1
