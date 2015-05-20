-- showrole.sql
-- show roles for a user or role

set verify off


accept WhichUser CHAR PROMPT "Roles for which user or role? - ";

select 
	granted_role, 
	admin_option,
	default_role
from dba_role_privs
where grantee = upper('&WhichUser')
order by granted_role
/

