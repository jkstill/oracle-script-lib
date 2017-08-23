
col logoff_time format a25
col logon_time format a25
col os_user format a15
col result format a20
col action_name format a20

set line 120

select * 
from session_audit
where username like '%'
order by logon_time
/
