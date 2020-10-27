
-- supp-tab-info.sql
-- show supplemental logging info for tables

col cuser noprint new_value uuser
prompt Supplemental Table Logging infor for which account?:
set term off feed off
select upper('&1') cuser from dual;
set term on feed on

col owner format a20
col table_name format a30
col log_group_name format a20
col log_group_type format a30
col always format a15

set linesize 200 trimspool oni
set pagesize 100

break on owner on	 table_name	 skip 1

select
	owner
	, table_name
	, log_group_name
	, log_group_type
	, always
from dba_log_groups
where owner like ('&uuser')
order by
	owner
	, table_name
/
