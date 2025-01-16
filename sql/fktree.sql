
-- fktree.sql
-- prototype SQL
-- find the tree of tables linked by FK
-- get the constraint names so we know how to find the columns
-- to use when looking for orphaned rows, and disparities in rows 
-- between the same tables on separate servers

@clears

-- example: call with @fktree SCHEMA TABLE_NAME

@@get-schema-name &1
@@get-table-name &2

col table_name format a30
col constraint_name format a30
col r_constraint_name format a30

set linesize 200 trimspool on
set pagesize 100

with fks as  (
	select c1.table_name
		, c1.constraint_name
		, c2.r_constraint_name
	from  dba_constraints c1
	left join dba_constraints c2
		on (
			c2.owner = c1.owner
	   	and c2.table_name = c1.table_name
			and c2.constraint_type='R'
		)
		and c1.constraint_type in ('U','P')
	where c1.owner = '&schema_name'
	and c2.r_constraint_name is not null
),
pks as (
	select c1.table_name, c1.constraint_name, null r_constraint_name
	from dba_constraints c1
	where c1.constraint_name in (
		select r_constraint_name
		from fks
	)
	and c1.owner = '&schema_name'
),
all_data as (
	select
		table_name
		, constraint_name
		, r_constraint_name
	from fks
	union 
	select 
		table_name
		, constraint_name
		, r_constraint_name
	from pks
)
select  distinct
	lpad(' ', 2 * (level - 1))|| table_name table_name
	, constraint_name
	, r_constraint_name
	, level
from all_data
start with table_name = '&u_table_name'
connect by nocycle prior constraint_name = r_constraint_name
 and level <=5 
--order by level
/


undef 1 2


