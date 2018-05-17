
-- tabcols.sql
-- show columns in alpha order for owner and table

@clears

set linesize 200 trimspool on
set pagesize 100

col u_own_name new_value u_own_name noprint
col u_tab_name new_value u_tab_name noprint

col index_name format a30
col column_name format a30
col data_type_size format a35
col data_size format a15
col nullable format a8

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



select tc.column_name
	--, rpad(tc.data_type,27,' ') || 
	, lpad(tc.data_type,27,' ') || ' ' || 
	case 
	when tc.data_type in ('VARCHAR2','CHAR','VARCHAR') then
		'('||tc.data_length||')'
	when tc.data_type in ('BINARY_DOUBLE','NUMBER','FLOAT','INTEGER','BINARY_FLOAT') then
		'('||nvl(tc.data_precision,38)||','||nvl(tc.data_scale,0)||')'
	else '('||to_char(data_length)||')'
	end data_type_size
	, decode(nullable,'Y','NULL','NOT NULL') nullable
from dba_tab_columns tc
where	 tc.owner = '&u_own_name'
	and tc.table_name = '&u_tab_name'
order by column_name
/

