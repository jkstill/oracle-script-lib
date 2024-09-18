
-- sysevent-top-10.sql
-- Show the top 10 foreground wait events in the database
-- Jared Still - 2024-09-18


set linesize 200 trimspool on

col name format a40
col total_waits_fg format 999,999,999
col time_waited_micro_fg format 9,999,999,999,999.099999
col time_waited format 99,999,999.099999
col average_wait_fg format 99,999,999.099999

with data as (
	select 
		n.name
		, e.total_waits_fg
		, e.time_waited_micro_fg 
		, e.average_wait_fg
	from v$system_event e
	join v$event_name n
		on n.event_id = e.event_id
		and n.wait_class = 'Other'
		and e.total_waits_fg > 1
	order by e.time_waited
)
select
	e.name
	, e.total_waits_fg
	, e.time_waited_micro_fg
	, e.time_waited_micro_fg / e.total_waits_fg time_waited , e.average_wait_fg
	--, e.average_wait_fg / 100 average_wait_cs
from data e
order by e.time_waited_micro_fg 
fetch first 10 rows only
/


