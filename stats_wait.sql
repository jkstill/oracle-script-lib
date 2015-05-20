
set linesize 200 pagesize 60

col sid format 99999
col username format a10
col event format a30
col p1text format a15
col p1 format 999999999999999
col p2text format a12
col p2 format 99999999999
col wait_time format 999999 head 'WAIT|TIME'
col seconds_in_wait format 999999 head 'SECONDS|IN|WAIT'
col state format a20
col seq format 999999 head 'SEQ'
col blocking_session format a8 head 'BLKING|INSTANCE|SESSION'
col wait_time_micro format 999,999,999 head 'WAIT TIME|MICROSECONDS'
col wait_time_seconds format 99.099999 head 'WAIT TIME|SECONDS'

select
	s.username username,
	e.event event,
	s.sid,
	s.sql_id,
	e.p1text,
	e.p1,
	e.p2text,
	e.p2,
	e.seq# seq,
	e.state,
	-- if state is 'WAITING' then wait_time is time in current wait
	-- otherwise it is time of most recent wait in centiseconds
	-- if -1 then wait was < .01 seconds
	-- if -2 then timed_statistics is not enabled
	e.wait_time,
	-- time of current or most recent wait in microseconds
	--e.wait_time_micro,
	e.wait_time_micro / 1000000 wait_time_seconds,
	--e.seconds_in_wait, -- a confusing and somewhat useless column - see 11g docs for v$session
	decode(s.blocking_session, null,'',s.blocking_instance || ':' || s.blocking_session) blocking_session
from v$session s, v$session_wait e
where s.username is not null
	and s.sid = e.sid
	-- skip sqlnet idle session messages
	and s.module like 'Gathering Stats :EMT%'
order by s.username, upper(e.event)
/


