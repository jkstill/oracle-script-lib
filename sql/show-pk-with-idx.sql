-- showpk.sql - show primary key constraints

col tablename format a30
col indexname format a30
col tablespace_name format a20 head 'TABLESPACE'
col constraintname format a30
col columnname format a30
col pos format 999
col status format a10

set linesize 200 trimspool on
set pagesize 100

set echo off

break on tablename skip 1 on constraintname skip 1

select 
	a.table_name tablename,
	a.constraint_name constraintname ,
	a.status status,
	b.column_name columnname,
	b.position pos,
	a.index_name indexname,
	i.tablespace_name
from all_constraints a
join all_cons_columns b
on  a.table_name not like 'BIN$%'
	and a.table_name = b.table_name
	and a.constraint_name = b.constraint_name
	and a.constraint_type = 'P'
	and a.owner = b.owner
	and a.owner = user
left outer join all_indexes i 
on a.index_name = i.index_name 
	and a.index_owner = i.owner
order by a.table_name,a.constraint_name, b.position
/
