
-- concurrency-waits-sqlid.sql
-- Jared Still 2023
-- report on SQL_ID with concurrency waits
-- due to reliance on v$session, this report can changes quite a bit between runs
-- this report also reports on a greater accumulation of data than does the ASH report
-- concurrency-waits-sqlid-ash.sql is a more stable report, but requires using ASH

/*

Yes, summing and averaging TIME_WAITED from ASH/AWR is "wrong"

This is because not all waits are captured in ASH, and AWR is a 10% sample

However, if a significant amount of time appears, I believe it is good to know that.

Just keep in mind that the amount of time is not accurate, it is lower than the real amount of time

*/

col event format a35
col event_waits format 99,999,999,999 head "EVENT|WAITS"
col executions format 99,999,999,999 head "EXECUTIONS"
col event_timeouts format 99,999,999,999 head "EVENT|TIMEOUTS"
col event_time_waited format 99,999,999 head "EVENT TIME|WAITED|SECONDS"
col waits_per_exe format 99,990.90 head "TOTAL WAITS|PER EXEC"
col sql_id format a13 head 'SQL ID'


set linesize 200 trimspool on
set pagesize 200

clear break
break on sql_id skip 1 on executions on waits_per_exe

select distinct
	sess.sql_id,
	-- total executions for sql_id
	max(st.executions) over (partition by sess.sql_id) executions,
	-- ratio of all waits:per exe
	max(se.total_waits / st.executions) over (partition by sess.sql_id)	waits_per_exe,
	se.event,
	sum(se.total_waits) over (partition by sess.sql_id, se.event) event_waits,
	sum(se.total_timeouts) over (partition by sess.sql_id, se.event) event_timeouts,
	sum(se.time_waited/100) over (partition by sess.sql_id, se.event) event_time_waited
from v$session_event se
	, v$session sess
	, v$event_name e
	, v$sqlstats st
where e.wait_class = 'Concurrency'
and e.name = se.event
and sess.sid = se.sid
and sess.sql_id is not null
and sess.username is not null -- no BG processes
and st.sql_id = sess.sql_id
order by waits_per_exe, sql_id, event_waits
/

