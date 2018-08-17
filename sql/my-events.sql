
select sid, event, p1text, wait_time_micro
from v$session_wait
where lower(event) like '%net%'
and sid = sys_context('userenv','sid')
/
