
-- fk-circular-ref.sql
-- Jared Still - 2020-11-09 - 
-- jkstill@gmail.com 
--
-- Find circular references where two tables refer to each other via Foreign Key
--
-- This covers only the simplest cases.  A circular chain of refs will not be found


set linesize 200 trimspool on
set pagesize 100

col table_name format a30
col r_table_name format a30
col constraint_name format a30
col r_constraint_name format a30
col fk format a30
col pk format a30


col v_user new_value v_user noprint

prompt Schema for FK Refs? :

set term off feed off
select upper('&1') v_user from dual;
set term on feed on

-- this seems a hard way to get results, but it does work

with fk as (
	select
		a.table_name
		, a.constraint_name
		, a.r_constraint_name
	from dba_constraints a
	where a.owner = '&v_user'
		and a.constraint_type = 'R'
),
pk as (
	select
		a.table_name
		, a.constraint_name
		--, a.r_constraint_name
	from dba_constraints a
	where a.owner = '&v_user'
		and a.constraint_type = 'P'
),
data as (
	select
		pk.table_name
		, pk.constraint_name pk
		, fk.constraint_name fk
		, pk2.table_name r_table_name
	from pk
		join fk on fk.table_name = pk.table_name
		join pk pk2 on pk2.constraint_name = fk.r_constraint_name
)
select  distinct
	d1.table_name
	, d1.pk
	, d1.fk
	, d1.r_table_name
from data d1
	join data d2
		on d2.table_name = d1.r_table_name
		and d1.table_name = d2.r_table_name
order by 1,2
/

undef 1


