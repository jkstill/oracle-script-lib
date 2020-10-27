
-- supp-col-info.sql
-- show supplemental logging info for columns

@clears

col cuser noprint new_value uuser
prompt Supplemental Column Logging Report for which account?:
set term off feed off
select upper('&1') cuser from dual;
set term on feed on


col owner format a20
col table_name format a30
col column_name format a30
col log_group_name format a20
col log_group_type format a30
col always format a15
col position format 9999 head 'POS'

set linesize 200 trimspool on
set pagesize 100

break on owner on	 table_name	 skip 1

select
	owner
	, table_name
	, column_name
	, log_group_name
	, position
	, logging_property
from dba_log_group_columns
where owner like ('&uuser')
order by
	owner
	, table_name
/
