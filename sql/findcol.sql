
-- findcol.sql - jared still
-- jkstill@gmail.com

@clears
@columns
col owner format a10
col data_type format a20

set line 120

col ccolumn noprint new_value ucolumn
col cowner noprint new_value uowner

set term on echo off feed off
prompt This utility searches for columns in DBA_TAB_COLUMNS
prompt
prompt Account to search for column on (Partial Name OK) :
set feed off term off
select upper('&1') cowner from dual;
set term on
prompt  Column name to search for (Partial Name OK) :
set term off feed off
select upper('&2') ccolumn from dual;

set term on feed on

break on owner skip 1 on table_name skip 1 

select 
	owner,
	table_name,
	column_name,
	data_type
from dba_tab_columns
where owner like '%&&uowner%'
and column_name like '%&&ucolumn%'
order by owner, table_name, column_name
/

undef 1 2

