
clear break
clear col

set echo off pause off pages 60 line 100
set trimspool on

col cevent new_value uevent noprint
prompt Event Name ( Partial OK ):
set feed off term off
select '&1' cevent from dual;
set feed on term on

col username format a10
col event format a35
col total_waits format 9999999 head "TOTAL|WAITS"
col total_timeouts format 9999999 head "TOTAL|TIMEOUTS"
col time_waited format 9999999 head "TIME|WAITED|SECONDS"
col average_wait format 99999 head "AVG|WAIT|100ths"

break on username on sid skip 1 on report

select 
	sess.username,
	sess.sid,
	se.event,
	se.total_waits,
	se.total_timeouts,
	se.time_waited/100 time_waited,
	se.average_wait
from v$session_event se, v$session sess
where se.event like '&uevent%'
and sess.sid = se.sid
and sess.username is not null
order by username, sid
/

undef 1

