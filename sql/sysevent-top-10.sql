
-- sysevent-top-10.sql
-- Show the top 10 foreground wait events in the database
-- Jared Still - 2024-09-18


set linesize 200
set trimspool on

col name format a40
col total_waits_fg format 99,999,999,999,990
col time_waited_micro_fg format 9,999,999,999,990.099999
col time_waited format 99,999,990.099999
col average_wait_fg format 99,999,990.099999
col wait_class format a20

with data as (
	select
		n.name
		, e.total_waits_fg
		, e.time_waited_micro_fg / 1000000 time_waited_micro_fg
		, e.average_wait_fg / 100 average_wait_fg
		, n.wait_class
	from v$system_event e
	join v$event_name n
		on n.event_id = e.event_id
		--and n.wait_class = 'Other'
		and n.wait_class not in ('Idle')
		and e.total_waits_fg > 1
	order by e.time_waited_micro_fg desc
)
select
	e.name
	, e.total_waits_fg
	, e.time_waited_micro_fg
	, e.time_waited_micro_fg / e.total_waits_fg time_waited
	, e.average_wait_fg
	, e.wait_class
from data e
fetch first 10 rows only
/

