
-- idle-events.sql
-- Jared Still
-- list events considered by Oracle as 'idle'
-- some are misleading
-- for instance, 'SQL*Net message from client' is marked as 'idle'
-- this is not true from an application perspective.

set linesize 200 trimspool on
set pagesize 100

col event_name format a64

select e.name event_name
from v$event_name e
where e.wait_class = 'Idle'
order by lower(event_name)
/


