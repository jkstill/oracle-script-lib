

-- fk_hierarchy.sql
-- display hierarchy of tables based on foreign keys
-- all tables for a user

/*
This error may occur:
  ORA-32044: cycle detected while executing recursive WITH query

If so then uncomment the 'cycle' lines

Examine the output for is_cycle = 1

This can occur if a child table has a self referencing constraint


*/


col v_username new_value v_username noprint
prompt
prompt Username To Get Hierarchy for:
prompt

set echo off term off head off
select upper('&1') v_username from dual;
set term on head on
undef 1

col table_name format a50
col r_constraint_name format a30

set line 200 pagesize 50000 trimspool on
set verify off

var v_username varchar2(30)

exec :v_username := '&&v_username'

--define key_types='''P'',''U'''
define key_types='''P'''

with constraints as (
	select
		u1.owner
		, u1.table_name
		, u1.constraint_name pk_constraint_name
		, null fk_constraint_name
		, u1.r_owner
		, u1.r_constraint_name
	from dba_constraints u1
	where u1.owner = :v_username
		and u1.constraint_type in (&&key_types)
		and u1.table_name in (
			select /*+ no_merge */ table_name 
			from dba_constraints c1
			where owner = :v_username
			and constraint_type in (&&key_types)
			and constraint_name in ( -- has child tables
				select r_constraint_name
				from dba_constraints
				where owner = :v_username
				and r_constraint_name is not null
			)
			and not exists ( -- is not a child
				select 1
				from dba_constraints
				where owner = :v_username
				and constraint_type = 'R'
				and table_name = c1.table_name
			)
		) 
	union all
	select
		u1.owner
		, u1.table_name
		, u1.constraint_name pk_constraint_name
		, u2.constraint_name fk_constraint_name
		, u2.r_owner
		, u2.r_constraint_name
	from dba_constraints u1
	join dba_constraints u2 on u2.owner = u1.owner
		and u2.table_name = u1.table_name
		and u2.constraint_type ='R'
	where u1.constraint_type in (&&key_types)
		and u1.owner = :v_username
		and u2.r_constraint_name not in ( -- exclude self referencing constraints on child tables
			select constraint_name
			from dba_constraints c2
			where c2.owner = u1.owner
			and c2.table_name = u1.table_name
			and c2.constraint_type = 'P'
		)
),
heir (owner, table_name, pk_constraint_name, fk_constraint_name, r_owner,r_constraint_name, lvl) as (
	select
		a.owner
		, a.table_name
		, a.pk_constraint_name
		, a.fk_constraint_name
		, a.r_owner
		, a.r_constraint_name
		, 1 lvl
		--, 'A' code
	from constraints a
	where r_constraint_name is null
	union all
	select
		b.owner
		, b.table_name
		, b.pk_constraint_name
		, b.fk_constraint_name
		, b.r_owner
		, b.r_constraint_name
		, fk.lvl+1 lvl
		--, 'B' code
	from constraints b
	join heir fk
		on fk.pk_constraint_name = b.r_constraint_name
)
search depth first by table_name set table_order
--cycle pk_constraint_name set is_cycle to '1' default '0'
select
	lvl 
	, lpad(' ', 2 * (lvl - 1))|| table_name table_name
	, pk_constraint_name
	, r_constraint_name
	, fk_constraint_name
	--, is_cycle
from heir
order by table_order
/

