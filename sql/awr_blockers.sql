
-- awr_blockers.sql
-- show historic blocking , sql_id and whether mode 4 (ITL) or mode 6 (rowlock)
-- Jared Still
-- 
-- jkstill@gmail.com

/*

As seen in an AWR report for 'Top Event P1/P2/P3 Values'

Event	                     % Event P1, P2, P3 Values	               % Activity  Parameter 1 Parameter 2   Parameter 3
enq: TX - index contention	22.52	  "1415053316","19529734","1548062"	1.65 	      name|mode   usn<<16|slot   sequence

P1 of 1415053316 is a mode 4 ITL wait
P1 of 1415053318 is a mode 6 ITL wait

This can be seen from the binary representation of these values

Mode 4
1415053316
0x54580004
1010100010110000000000000000100

$  perl -e 'print 1415053316 & 0xFFFF, "\n"'
4

Mode 6
1415053318
0x54580006
1010100010110000000000000000110

$  perl -e 'print 1415053318 & 0xFFFF, "\n"'
6

*/

@clears

@get_date_range

set tab off
-- d_date_format set by get_date_range.sql

with waits as (
	select
		sh.instance_number
		, sh.blocking_inst_id
		, sh.sql_id
		, bitand(sh.p1,65535) lockmode
	from DBA_HIST_ACTIVE_SESS_HISTORY sh
	join dba_hist_snapshot s on s.snap_id = sh.snap_id
   	and s.snap_id = sh.snap_id
   	and s.instance_number = sh.instance_number
	where sh.blocking_inst_id is not null
	and sh.event_id = ( select event_id from v$event_name where name like 'enq: TX - row lock contention')
	and s.begin_interval_time between to_date('&&d_begin_date','&&d_date_format') and to_date('&&d_end_date','&&d_date_format')
)
select
	w.instance_number
	, w.blocking_inst_id
	, w.sql_id
	, decode(w.lockmode, 4,'ITL',6,'ROWLOCK','UNKNOWN') lockmode
	, count(*) * 10 waitcount -- only sampled every 10 seconds from gv$active_session_history
from waits w
group by 
	w.instance_number
	, w.blocking_inst_id
	, w.sql_id
	, w.lockmode
order by waitcount
/

