
-- dba_audit_trail_persons.sql
-- show activity on audited objects
--
-- joins to persons table on vdrprod database
-- to show employee names

-- audit flags in the ses_actions header
-- are the first letter of each of the folowing, 
-- in order of appearance:
-- ALTER AUDIT COMMENT DELETE GRANT INDEX INSERT LOCK RENAME SELECT UPDATE REFERENCES EXECUTE

@clears
@columns

set linesize 150 
set pagesize 60

col obj_name format a30 head 'OBJECT NAME'
col priv_used format a20 head 'PRIVILEGE USED'
col ses_actions format a13 head 'AACDGIILRSURE'
col os_username format a15 head 'OS USER'
col terminal format a15 head 'MACHINE'
col fullname format a20 head 'FULL NAME'

clear break
break on owner skip 1 on obj_name skip 1


select
	owner
	, obj_name
	, os_username
	, p.first_name || ' ' || p.last_name fullname
	, username
	--, terminal
	, to_char(timestamp,'dd-mon hh24:mi') timestamp
	--, action_name
	--, priv_used
	, ses_actions
from sys.dba_audit_trail a, prjstat.persons@vdrprod p
where p.login_id(+) = lower(a.os_username)
and not exists (
	select null
	from prjstat.persons@vdrprod p
	where 
		lower(substr(p.first_name,1,1)) = lower(substr(a.username,1,1))
		and
		lower(p.last_name) like lower(substr(a.username,2))||'%'
)
union
select
	owner
	, obj_name
	, os_username
	, p.first_name || ' ' || p.last_name fullname
	, username
	--, terminal
	, to_char(timestamp,'dd-mon hh24:mi') timestamp
	--, action_name
	--, priv_used
	, ses_actions
from sys.dba_audit_trail a, prjstat.persons@vdrprod p
where 
	lower(substr(p.first_name,1,1)) = lower(substr(a.username,1,1))
	and
	lower(p.last_name) like lower(substr(a.username,2))||'%'
order by owner, obj_name, timestamp
/

