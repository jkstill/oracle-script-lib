
-- tabidx.sql
-- show indexes per table 
-- 
-- it is assumed that index_owner = table_owner


@clears

col u_own_name new_value u_own_name noprint
col u_tab_name new_value u_tab_name noprint

col index_name format a30
col column_name format a30

break on index_name skip 1

prompt 
prompt Owner:
prompt 

set feed off head off term off
select upper('&1') u_own_name from dual;
set feed on head on term on

prompt 
prompt Table Name: 
prompt 

set feed off head off term off
select upper('&2') u_tab_name from dual;
set feed on head on term on



select ic.index_name, ic.column_name, i.visibility
from dba_ind_columns ic
	,dba_indexes i
where	 ic.table_owner = '&u_own_name'
	and ic.table_name = '&u_tab_name'
	and i.owner = ic.index_owner
	and i.table_owner = ic.table_owner
	and i.table_name = ic.table_name
	and i.index_name = ic.index_name
order by index_name, column_position
/
