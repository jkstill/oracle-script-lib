

-- duplicate a role

@clears

col crole noprint new_value urole
prompt Duplicate which role? :
set term off feed off
select lower('&&1') crole from dual;
set term on

define dup_file=_&&urole._grant.sql

set echo off term on feed off 
set trimspool on
set verify off pages 0 line 200

spool &&dup_file

prompt create role &&urole;;

select
	'grant ' || privilege || ' on ' || owner  || '.' || table_name || ' to ' || grantee || ';'
from dba_tab_privs
where grantee like upper('&&urole')
union all
select
	'grant ' || privilege || ' to ' || grantee || 
	decode(admin_option, 'NO', ';', 'YES', ' with admin option;')
from dba_sys_privs
where grantee like upper('&&urole')
union all
select
	'grant ' || granted_role || ' to ' || grantee || 
	decode(admin_option, 'NO', ';', 'YES', ' with admin option;')
from dba_role_privs
where grantee like upper('&&urole')
/

spool off
set echo off feed on

undef 1

