
-- dup_user.sql
-- can call from command line
--    e.g.  @dup_user OLD_USERNAME NEW_USERNAME
-- duplicate a user with a new name, same privs.
-- does NOT move objects
-- you must run the generated file manually
-- you will also have to manually drop the old user


@clears

col colduser new_value uolduser noprint
col cnewuser new_value unewuser noprint
col cspoolfile new_value uspoolfile noprint

prompt Old Username:
set term off feed off
select upper('&1') colduser from dual;
set term on feed on

prompt New Username:
set term off feed off
select upper('&2') cnewuser from dual;

select '_' || lower(replace('&unewuser','$','\$')) || '.sql'  cspoolfile from dual;

set term on feed on

@clear_for_spool


spool &uspoolfile

prompt set echo on

select 'create user &unewuser identified by values ' ||  '''' || p.password || '''' || 
	' default tablespace ' || default_tablespace || 
	' temporary tablespace '  || temporary_tablespace || ';'
from dba_users u, sys.user$ p
where u.username = upper('&uolduser')
and p.name = u.username
/

select 'alter user &unewuser quota ' || 
decode(max_bytes, -1, ' UNLIMITED ', max_bytes ) || ' on ' ||
tablespace_name || ';'
from dba_ts_quotas
where username = upper('&uolduser')
/


select 'grant ' || granted_role || ' to &unewuser;'
from dba_role_privs
where grantee = upper('&uolduser')
union
select 'grant ' || privilege || ' to &unewuser ' || decode(admin_option,'YES',' with admin option','') || ';'
from dba_sys_privs
where grantee = upper('&uolduser')
union
select 'grant '
	|| decode(privilege,
		'READ', 'READ on directory ',
		'WRITE', 'WRITE on directory ',
		privilege || ' on '
	) 
	|| owner || '.' || table_name || ' to &unewuser;'
from dba_tab_privs
where grantee = upper('&uolduser')
--order by 1, 2, 3, 4, 5
/

prompt set echo off

spool off

@clears

prompt
prompt The file '&uspoolfile' will create the new user '&unewuser'
prompt


