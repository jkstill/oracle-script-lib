
-- concurrency-waits-sqlid-ash.sql
-- Jared Still 2023
-- report on SQL_ID with concurrency waits

col username format a10
col event format a35
col total_waits format 99,999,999,999 head "TOTAL|WAITS"
col event_waits format 99,999,999,999 head "EVENT|WAITS"
col total_timeouts format 99,999,999,999 head "TOTAL|TIMEOUTS"
col time_waited format 99,999,999 head "TIME|WAITED|SECONDS"
col sql_id format a13 head 'SQL ID'


set linesize 200 trimspool on
set pagesize 200

clear break
break on sql_id skip 1

select distinct
	ash.sql_id,
	ash.event,
	count(*) over (partition by ash.sql_id, ash.event) event_waits,
	count(*) over (partition by ash.sql_id) total_waits
	-- get time waited if necessary
	-- kind of tricky, see v$active_session_history docs for TIME_WAITED column
from v$active_session_history ash
join v$event_name e
	on e.event_id = ash.event_id
	and e.wait_class = 'Concurrency'
	and ash.session_state = 'WAITING'
order by total_waits, sql_id, event_waits
/

