
-- sesswaitu.sql
-- show current waits for a username
-- may call as '@sesswaitu USERNAME'
-- eg. @sesswaitu '%'
-- eg. @sesswaitu '%TMR%'
-- eg. @sesswaitu 'USSP'
-- if username not passed, it will ask for it
	
set line 110 feed on pause off echo off
set trimspool on
set verify off

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
col wait_time format 999999 head 'WAIT|TIME'
col seconds_in_wait format 999999 head 'SECONDS|IN|WAIT'
col state format a20

break on username skip 1 on event

select
	s.username username,
	e.event event,
	s.sid,
	e.p1text,
	e.wait_time,
	e.seconds_in_wait,
	e.state
from v$session s, v$session_wait e
where s.username is not null
	and s.sid = e.sid
	and s.username like upper('&uusername')
order by s.username, upper(e.event)
/

undef 1

