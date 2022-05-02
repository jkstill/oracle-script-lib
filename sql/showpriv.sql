
-- showpriv.sql
-- show roles and privileges for a user or role
-- jkstill - 10/26/1999 - allow user to specify wildcards
--                        rather than forcing in the SQL

-- don't skip a line when table_name wraps
set recsep off	
set verify off
set pause off echo off
set trimspool on
set line 200 trimspool on

col grantee format a10 head 'GRANTEE'
col privtype heading 'PRIV|TYPE'
col privname heading 'PRIV NAME' format a22
col owner format a10
col table_name format a27

clear break
break on grantee on privtype


col cuser noprint new_value WhichUser
PROMPT "Roles/Privileges for which user or role? - ";
prompt ( Wildcards OK )
set term off feed off
select '&1' cuser from dual;
set term on feed on

select grantee, 'ROLE' privtype, granted_role privname, null owner, null table_name, admin_option grantable
from dba_role_privs
--where grantee = upper('&WhichUser')
where grantee like upper('&WhichUser')
union
select grantee, 'SYSPRIV' privtype, privilege privname, null owner, null table_name, admin_option grantable
from dba_sys_privs
--where grantee = upper('&WhichUser')
where grantee like upper('&WhichUser')
union
select grantee, 'TABPRIV' privtype, privilege privname, owner, table_name, grantable
from dba_tab_privs
--where grantee = upper('&WhichUser')
where grantee like upper('&WhichUser')
order by 1, 2, 3, 4, 5
/


-- reset
set recsep wrapped

undef 1

