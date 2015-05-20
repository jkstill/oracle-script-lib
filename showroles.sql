-- showpriv.sql
-- show all roles and privs granted to them

set verify off

col privtype heading 'PRIV|TYPE'
col role format a17
col priv heading 'PRIVILEGE'

clear breaks
break on role skip 2

@title80 'Roles & SysPrivs/Roles Assigned To Them'

select 
	a.role, 
	b.granted_role  priv , 
	'ROLE' privtype
from dba_roles a, dba_role_privs b
where b.grantee = a.role
	and b.granted_role <> a.role
union
select 
	a.role,
	b.privilege priv , 
	'PRIV' privtype
from dba_roles a, dba_sys_privs b
where b.grantee = a.role
order by 1,2,3
/

