

-- col-diff.sql
-- originally from https://renenyffenegger.ch
-- and modified to accept variable names
-- jkstill@gmail.com - 2022

@clears

col v_owner new_value v_owner noprint
col v_tab_a new_value v_tab_a noprint
col v_tab_b new_value v_tab_b noprint

prompt 'Owner: ' 
set term off feed off
select upper('&1') v_owner from dual;

set term on
prompt 'Table A:'
set term off
-- change V$ to V_$ for data dictionary lookup
select replace(upper('&2'),'V$','V_$') v_tab_a from dual;

set term on
prompt 'Table B:'
set term off
select replace(upper('&3'),'V$','V_$') v_tab_b from dual;

set term on


col col_name format a30
col IN_A format a4
col IN_B format a4

set linesize 200 trimspool on
set pagesize 100

prompt
prompt A: &v_tab_a
prompt B: &v_tab_b
prompt

with 
	a as (select * from dba_tab_columns where owner = '&v_owner' and table_name = '&v_tab_a'),
	b as (select * from dba_tab_columns where owner = '&v_owner' and table_name = '&v_tab_b')
select
	coalesce(a.column_name, b.column_name)          col_name,
	-- the decode and case are equivalent
	decode(a.column_id,null,'','X') in_a,
	--case when a.column_id is not null then 'X' else '' end in_a,
	case when b.column_id is not null then 'X' else '' end in_b
from a 
full outer join b on a.column_name = b.column_name
order by
    --coalesce (a.column_name, b.column_name) - 
	 -- named columns works from at least 10gR2
    col_name
/


