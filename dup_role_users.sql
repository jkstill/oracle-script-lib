
-- dup_role_users.sql
-- generate DDL to duplicate a set of users granted a particular role(s)
--
-- the section that grants table priviliges only 
-- works for a single schema owner
--


col cowner noprint new_value uowner
col crolename noprint new_value urolename

prompt This script generates a script to duplicate all users that have
prompt been granted a particular role of set of roles
prompt
prompt the default for the password is the same as the username
prompt there is a line to uncomment that will use the real password
prompt
prompt This script will only do the table grants for a single schema owner
prompt which is fine for most uses of this script
prompt

prompt Shema Owner? :
set term off feed off 
select upper('&1') cowner from dual;

set term on feed on
prompt Duplicate users assigned this Role[s] 
prompt (  you may use the wildcard character '%' ) :

set term off feed off
select upper('&2') crolename from dual;
set term on feed on

@clear_for_spool

spool _dup_role_users.sql

prompt
prompt
prompt -- create user
prompt
prompt

prompt set echo on feed on term on

prompt
prompt prompt Duplicating Users/Quota/System Privileges For All Users  Of Roles Like '&urolename'
prompt
prompt prompt Granting Table Privileges To All Users Of Tables Owned by '&uowner' 
prompt prompt That Are Also Assigned To Roles Like '&urolename'
prompt


select distinct
	'create user ' || grantee 
	--|| ' identified by ' || grantee 
	|| ' identified by values ' || '''' || password || '''' 
	|| ' default tablespace ' || default_tablespace 
	|| ' temporary tablespace ' || temporary_tablespace 
	|| ' profile ' || profile
	|| ';'
from dba_role_privs rp, dba_users u
where granted_role like '&urolename'
and u.username = rp.grantee
and exists ( select null from dba_roles where role = rp.granted_role )
and exists ( select null from dba_users where username = rp.grantee )
/

prompt
prompt
prompt -- grant quotas
prompt
prompt

select  'alter user ' || q.username || ' quota ' 
	|| decode(max_bytes,
		-1, 'UNLIMITED',
		to_char( max_bytes/ 1048576 ) || 'M'
	) 
	|| ' on ' || q.tablespace_name  || ';'
from dba_ts_quotas q, dba_role_privs rp
where rp.granted_role like '&urolename'
and q.username = rp.grantee
order by username, tablespace_name
/

prompt
prompt
prompt -- grant roles
prompt
prompt

select  'grant ' || granted_role || ' to ' || grantee || ';'
from dba_role_privs
where granted_role like '&urolename'
/

prompt 
prompt 
prompt -- sys privs
prompt 
prompt 

select distinct 'grant ' || sp.privilege || ' to ' || sp.grantee || ';'
from dba_sys_privs sp, dba_role_privs rp
where rp.granted_role like '&urolename'
and sp.grantee = rp.grantee
order by 1
/

prompt 
prompt 
prompt -- tab privs
prompt 
prompt 

select 'grant ' || tp.privilege || ' on ' || tp.table_name ||  ' to ' || tp.grantee || ';'
from dba_tab_privs tp, dba_role_privs rp
where rp.granted_role like '&urolename'
and tp.grantee = rp.grantee
and owner = '&uowner'
order by 1
/

prompt 
prompt 
prompt -- all done
prompt 
prompt 

prompt set echo off

spool off

prompt
prompt run _dup_role_users.sql to create the accounts
prompt

@clears

undef 1 2 3


