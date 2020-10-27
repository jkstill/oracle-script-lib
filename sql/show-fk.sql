
-- show-fk.sql - report foreign key constraints

@clears

col cuser noprint new_value uuser
prompt FK Columns for which account?:
set term off feed off
select upper('&1') cuser from dual;
set term on feed on

col owner format a10
col table_name format a30 head 'TABLE'
col parent_table format a30 head 'PARENT TABLE'
col column_name format a30 head 'COLUMN'
col constraint_name format a30 head 'FK CONSTRAINT'
col position format 999 head 'POS'
col delete_rule format a11 head 'DELETE RULE'

set linesize 200 trimspool on
set pagesize 100

break on owner on table_name on constraint_name skip 1

select
	col.owner
	, col.table_name
	, col.constraint_name
	, col.column_name
	, col.position
	, con.parent_table
	, con.delete_rule
from (
	select distinct
		c.owner owner
		, c.table_name table_name
		, c.constraint_name constraint_name
		, p.table_name parent_table
		, c.delete_rule
	from dba_constraints c, dba_constraints p
	where c.r_constraint_name = p.constraint_name
	and c.r_owner = p.owner
	and p.owner = '&&uuser'
) con,
	dba_cons_columns col
where con.owner = col.owner
and con.constraint_name = col.constraint_name
and con.table_name = col.table_name
order by 1,2,3,5
/

undef 1
