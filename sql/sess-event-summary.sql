
-- sess-event-summary.sql
-- Jared Still 2023
-- summary of all non-idle events for all sessions
-- 'SQL*Net message from client' is included

/*

Yes, summing and averaging TIME_WAITED from ASH/AWR is "wrong"

This is because not all waits are captured in ASH, and AWR is a 10% sample

However, if a significant amount of time appears, I believe it is good to know that.

Just keep in mind that the amount of time is not accurate, it is lower than the real amount of time

*/

/*
 INST                                                                                        MIN                 MAX                 AVG
   ID EVENT                                                      TIME WAITED         TIME WAITED         TIME WAITED         TIME WAITED EVENT_COUNT
----- -------------------------------------------------- ------------------- ------------------- ------------------- ------------------- -----------
    1 SQL*Net more data to client                                   0.000029            0.000029            0.000029            0.000029           1
    1 RMAN backup & recovery I/O                                    0.000061            0.000016            0.000024            0.000020           3
    1 enq: TX - row lock contention                                 0.001052            0.001052            0.001052            0.001052           1
    1 library cache: bucket mutex X                                 0.001471            0.000001            0.000690            0.000098          15
...
    1 log file switch (checkpoint incomplete)                 210,312.280690          117.048466       61,937.004746        2,336.803119          90
    1 buffer busy waits                                       232,623.698789            0.000001      197,428.058974        2,303.204939         101
    1 log file switch (archiving needed)                      270,109.930933       29,906.355403       30,382.703478       30,012.214548           9
    1 log file parallel write                                 407,801.456572          306.854240      222,247.765851      135,933.818857           3
    1 db file async I/O submit                                416,703.871105      416,703.871105      416,703.871105      416,703.871105           1
    1 events in waitclass Other                               547,279.660292            0.000007      338,308.124985        2,545.486792         215

51 rows selected.
*/

col inst_id format 9999 head 'INST|ID'
col event format a50
set pagesize 100
set linesize 200 trimspool on
col time_waited_seconds format 999,999,990.099999 head 'TIME WAITED'
col time_waited_seconds_min format 999,999,990.099999 head 'MIN|TIME WAITED'
col time_waited_seconds_max format 999,999,990.099999 head 'MAX|TIME WAITED'
col time_waited_seconds_avg format 999,999,990.099999 head 'AVG|TIME WAITED'

with data as (
	select 
		inst_id
		, event
		, sum(time_waited_micro/1000000) time_waited_seconds
		, min(time_waited_micro/1000000) time_waited_seconds_min
		, max(time_waited_micro/1000000) time_waited_seconds_max
		, avg(time_waited_micro/1000000) time_waited_seconds_avg
		, count(*) event_count
	from gv$session_event
	where wait_class != 'Idle'
	group by inst_id, event
	union all
	select 
		inst_id
		, event
		, sum(time_waited_micro/1000000) time_waited_seconds
		, min(time_waited_micro/1000000) time_waited_seconds_min
		, max(time_waited_micro/1000000) time_waited_seconds_max
		, avg(time_waited_micro/1000000) time_waited_seconds_avg
		, count(*) event_count
	from gv$session_event
	where event = 'SQL*Net message from client'
	and time_waited_micro < 1e6
	group by inst_id, event
)
select 
	inst_id
	, event
	, time_waited_seconds
	, time_waited_seconds_min
	, time_waited_seconds_max
	, time_waited_seconds_avg
	, event_count
from data
order by 3
/

