
clear break
clear col

set echo off pause off pages 60 line 100
set trimspool on

@who2

col csid new_value usid noprint
prompt SID Value:
set feed off term off
select '&1' csid from dual;
set feed on term on

col username format a10
col event format a35
col total_waits format 9999999 head "TOTAL|WAITS"
col total_timeouts format 9999999 head "TOTAL|TIMEOUTS"
col time_waited format 9999999 head "TIME|WAITED|SECONDS"
col average_wait format 99999 head "AVG|WAIT"

break on username on sid skip 1

select 
	sess.username,
	sess.sid,
	se.event,
	se.total_waits,
	se.total_timeouts,
	se.time_waited/100 time_waited,
	se.average_wait
from v$session_event se, v$session sess
where  sess.sid = &usid
and sess.sid = se.sid
order by event
/

undef 1

