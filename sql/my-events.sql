
col event format a40
col p1text format a40

set linesize 200
set pagesize 100

select sid, event, p1text, wait_time_micro
from v$session_wait
where sid = sys_context('userenv','sid')
--and lower(event) like '%net%'
/
