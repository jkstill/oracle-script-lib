

-- fktree-rcte.sql
-- Create a tree of tables based on FK relations
-- This is the RCTE (Recursive Common Table Expression) version
-- Jared Still - Pythian 2020-11-04
-- jkstill@gmail.com still@pythian.com


/*

The RCTE (Recursive Common Table Expression) version is encountering a bug in Oracle 19.8

Bug 30877518 - ORA-600[qctcte1] From SQL Statement With A With-clause (Doc ID 30877518.8)

====

SYS@ora192rac-scan/pdb4.jks.com AS SYSDBA> @fktc
from fktree d
*
ERROR at line 43:
ORA-00600: internal error code, arguments: [qctcte1], [0], [], [], [], [], [], [], [], [], [], []

When testing on an 11g database, this query is not returning all the rows expected.

There must be some error I have made in the SQL, but so far I cannot determine what the problem is

If you fix it, please share

*/

@clears

col owner format a20
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


with fktree (
	owner
	, table_name
	, constraint_name
	, constraint_type
	, r_constraint_name
	, delete_rule
	, lvl
	, idx
) as (
	select
		c.owner
		, c.table_name
		, c.constraint_name
		, c.constraint_type
		, null r_constraint_name
		, c.delete_rule
		, 1 as lvl
		, rownum - 1 as idx
	from all_constraints c
	where c.owner = '&v_user'
		and c.constraint_type in ('U','P')
	union all
	select
		  c.r_owner
		, c.table_name
		, c.constraint_name
		, c.constraint_type
		, c.r_constraint_name
		, c.delete_rule
		, fkt.lvl+1 as lvl
		, fkt.idx+1 as idx
	from all_constraints c
	join fktree fkt on
		fkt.constraint_name = c.r_constraint_name 
		and fkt.owner = c.r_owner
		and c.constraint_type in ('R')
)
search depth first by table_name set table_order
select
	lpad(' ',(lvl-1)*2) || d.table_name table_name
	, r_constraint_name
	, constraint_name
	, delete_rule
	, level lvl
	, idx
	-- , CONNECT_BY_ISCYCLE -- look up documentation for this
from fktree d
--/*
start with d.table_name in (
	select table_name
	from dba_constraints
	where owner = '&v_user'
		and constraint_type in ('U','P')
	minus
	select table_name
	from dba_constraints
	where owner = '&v_user'
		and constraint_type = 'R'
)
--*/
connect by  prior constraint_name = r_constraint_name
	--and level <= 5
order by table_order
/

undef 1

