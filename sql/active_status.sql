

-- active_status.sql
-- show only active sessions
-- if not on a wait event, then on CPU

set linesize 200 trimspool on
set pagesize 60

col event format a30

SELECT
   NVL(s.username,s.program) username
 , s.sid                     sid
 , s.serial#                 serial
 , s.sql_hash_value          sql_hash_value
 , SUBSTR(DECODE(w.wait_time
               , 0, w.event
               , 'ON CPU'),1,15) event
 , w.p1                          p1
 , w.p2                          p2
 , w.p3 p3
 from v$session s
 , v$session_wait  w
 where w.sid=s.sid
 and s.status='ACTIVE'
   AND s.type='USER';
