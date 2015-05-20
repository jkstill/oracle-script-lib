-- showpk.sql - show primary key constraints

col tablename format a24
col constraintname format a24
col columnname format a24
col pos format 999

set echo off

break on tablename skip 1 on constraintname skip 1

select 
	a.table_name tablename,
	a.constraint_name constraintname ,
	b.column_name columnname,
	b.position pos
from user_constraints a, user_cons_columns b
where a.table_name = b.table_name
	and
	a.constraint_name = b.constraint_name
	and
	a.table_name = (
	select c.table_name
	from ctp_audit_tables c
	where c.table_name = a.table_name
	)
	and a.constraint_type = 'P'
order by a.table_name,a.constraint_name, b.position
/
