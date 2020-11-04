
-- fktree.sql
-- Create a tree of tables based on FK relations
-- Jared Still - Pythian 2020-11-04
-- jkstill@gmail.com still@pythian.com

@clears

col parent format a30
col child format a30
col table_name format a30
col parent_pk_name format a30
col constraint_name format a30
col r_constraint_name format a30

col constraint_type format a30
col child format a30
col child_fk_name format a30
col r_parent_pk_name format a30

set linesize 200 trimspool on
set pagesize 100

col v_user new_value v_user noprint

prompt Schema for FK Tree? :

set term off feed off
select upper('&1') v_user from dual;
set term on feed on


with data as
(
	select
		c.table_name
		, c.constraint_name
		, c.constraint_type
		, c.r_constraint_name
		, c.delete_rule
	from all_constraints c
	where c.owner = '&v_user'
		and c.constraint_type in ('R','U','P')
)
select
	lpad(' ',(level-1)*2) || d.table_name table_name
	, r_constraint_name
	, constraint_name
	, delete_rule
	--, level
from data d
connect by nocycle prior constraint_name = r_constraint_name
start with constraint_type in ('P','U')
/

undef 1

