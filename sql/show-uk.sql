-- show-uk.sql - show unique key constraints

@clears

col cuser noprint new_value uuser
prompt UK Columns for which account?:
set term off feed off
select upper('&1') cuser from dual;
set term on feed on

col table_name format a30
col constraintname format a30
col columnname format a30

col delete_rule heading	 'DELETE RULE' format	a11
col position heading	 'POS' format	 999
col constraint_name heading  'FK CONSTRAINT' format	a30
col column_name heading	 'col' format	 a30
col parent_table heading  'PARENT TABLE' format	  a30
col owner format	 a15


set pagesize 100
set linesize 200 trimspool on

set echo off

break on table_name skip 1 on constraintname skip 1

select
	col.owner
	, col.table_name
	, col.constraint_name
	, col.column_name
	, col.position
	, con.delete_rule
from (
	select distinct
		c.owner owner
		, c.table_name table_name
		, c.constraint_name constraint_name
		, c.delete_rule
	from dba_constraints c
	where c.owner = '&&uuser'
	and constraint_type = 'U'
) con
	, dba_cons_columns col
where con.owner = col.owner
and con.constraint_name = col.constraint_name
and con.table_name = col.table_name
order by 1,2,3,5
/

undef 1
