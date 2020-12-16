
clear col
clear break
clear compute


col event format a35 head 'EVENT NAME'
col total_waits format 999,999,999 head "TOTAL|WAITS"
col total_timeouts format 999,999,999 head "TOTAL|TIMEOUTS"
col time_waited format 999,999,999 head "TIME|WAITED|SECONDS"
col average_wait format 9999999.99 head "AVG|WAIT"
col stime new_value start_time noprint
col etime new_value end_time noprint
col sectime new_value seconds noprint
col global_name new_value dbname noprint


-- get db
select 'Database: ' || global_name global_name from global_name;
-- set the start_time
select to_char(begin_time,'mm/dd/yyyy hh24:mi:ss') stime from sysevent_snap;
-- set the end_time
select to_char(end_time,'mm/dd/yyyy hh24:mi:ss') etime from sysevent_snap;

-- get the difference in seconds ( end_time - start_time )
select 
		round((end_time - begin_time) / ( 1/(24*60*60))) sectime
from sysevent_snap
/

ttitle on
ttitle 'System Event  for &dbname' skip 'Start Time:  &start_time' skip 'End Time  :  &end_time' skip 'Seconds: &seconds' skip 2

set linesize 150 trimspool on
set pagesize 100
set trimspool on


select
	b.inst_id,
	b.event,
	e.total_waits - b.total_waits total_waits,
	e.total_timeouts - b.total_timeouts  total_timeouts,
	-- time waited already converted to whole seconds by sysevent_begin.sql
	-- and sysevent_stored. It is stored as centiseconds in v$system_event
	(e.time_waited - b.time_waited) time_waited,
	-- the 0.000001 is a fudge factor to prevent division by 0
	(e.time_waited - b.time_waited) / ((e.total_waits - b.total_waits) + 0.000001 )average_wait
from sysevent_begin b, sysevent_end e
where 
	b.inst_id = e.inst_id
	and b.event = e.event
	and e.total_waits - b.total_waits > 0
order by time_waited
/


ttitle off


