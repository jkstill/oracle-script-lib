
-- sesswaitu.sql
-- show current waits for a username
-- may call as '@sesswaitu USERNAME'
-- eg. @sesswaitu '%'
-- eg. @sesswaitu '%TMR%'
-- eg. @sesswaitu 'USSP'
-- if username not passed, it will ask for it
	
set line 190 feed on pause off echo off verify off
set trimspool on

clear col
clear break

col cusername new_value uusername
prompt Enter Username:
set feed off echo off term off
select '&1' cusername from dual;
set term on feed on


col sid format 99999
col username format a10
col event format a30
col p1text format a10
col p1 format 99999999999
col p2text format a15
col p2 format 99999999999
col wait_time format 999999 head 'WAIT|TIME'
col seconds_in_wait format 999999 head 'SECONDS|IN|WAIT'
col state format a20
col seq format 999999 head 'SEQ'
col seconds_waited format 99.9990
col state format a16
col wait_time_micro format 999,999,999,999 head 'WAIT|TIME|MICRO'
col sql_id format a13

break on username skip 1 on event


select
	s.username username,
	e.event event,
	s.sid,
	s.sql_id,
	e.p1text,
	mod(e.p1,16) p1,
	e.p2text,
	e.p2,
	e.seq# seq,
	e.state,
	e.wait_time_micro
	--case wait_time 
	--when 0 (SECONDS_IN_WAIT - WAIT_TIME / 100)
	--else 0
	--end seconds_waited,
from v$session s, v$session_wait e
where s.username is not null
	and s.sid = e.sid
	and s.username like upper('&uusername')
	-- skip sqlnet idle session messages
	--and e.event not like '%message%client'
	--and s.wait_class != 'Idle'
	and e.state not like 'WAITED%'
order by s.username, upper(e.event)
/

prompt !! run dba_kgllock.sql or libcachepin_waits.sql to diagnose Library Cache Pin waits
prompt

undef 1

