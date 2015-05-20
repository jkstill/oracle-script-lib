

-- reverse_role_lookup.sql
-- lookup who is granted role(s)
-- wildcards accepted
-- linked to rrl.sql

@clears

set pagesize 60

col crole noprint new_value urole
prompt
prompt Reverse Role Lookups
prompt
prompt Find Grantees for which Role(s):
prompt  ( wildcards OK )
set term off feed off
select upper('&1') crole from dual;
set term on feed on

break on granted_role skip 1

select 
	granted_role
	,grantee 
from dba_role_privs
where granted_role like upper('&urole')
order by 1 ,2 
/

undef 1

