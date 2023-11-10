
-- awr-enq-hot-blocks.sql
-- Jared Still
-- 2023
-- jkstill@gmail.com

/*

Yes, summing and averaging TIME_WAITED from ASH/AWR is "wrong"

This is because not all waits are captured in ASH, and AWR is a 10% sample

However, if a significant amount of time appears, I believe it is good to know that.

Just keep in mind that the amount of time is not accurate, it is lower than the real amount of time

*/


/*

As seen in an AWR report for 'Top Event P1/P2/P3 Values'

Event								% Event P1, P2, P3 Values						% Activity	Parameter 1 Parameter 2	  Parameter 3
enq: TX - index contention 22.52	  "1415053316","19529734","1548062" 1.65			name|mode	usn<<16|slot	sequence

P1 of 1415053316 is a mode 4 ITL wait
P1 of 1415053318 is a mode 6 rowlock wait

This can be seen from the binary representation of these values

Mode 4
1415053316
0x54580004
1010100010110000000000000000100

$	perl -e 'print 1415053316 & 0xFFFF, "\n"'
4

Mode 6
1415053318
0x54580006
1010100010110000000000000000110

$	perl -e 'print 1415053318 & 0xFFFF, "\n"'
6

Note: when lockname = 'UL' the rows are excluded, as those are user defined locks
		this script is looking for system resource contention

*/


-- limit the report to at least 5 waits for a block
-- adjust as necessary
def u_wait_count_min=5

@clears

set pagesize 100
set linesize 200 trimspool on

col sql_id format a13 head 'SQL ID'
col current_obj#	format 999999999 head 'Obj#'
col lockname format a2 head 'LN'
col lockmode format a14 head 'LockMode'
col current_file# format 999999 head 'File#'
col current_block# format 9999999999 head 'Block#'
col wait_count format 99,999,999 head 'Wait|Count'
col time_waited format 999,999.09 head 'Time Waited|Seconds'
col time_waited_sum format 99,999,999.09 head 'Time Waited|Sum'
col sql_rank format 9999999 head 'SQL Rank'

-- call with something like this
-- @awr-enq-hot-blocks '2023-10-15 00:00:00' '2023-11-04 00:00:00'

@get_date_range

clear break
break on sql_id skip 1 on time_waited_sum

-- there is no need to check for session_state = 'WAITING', as these rows are by their nature, all waits
-- add the clause "and session_state = 'WAITING'" if you like, the results will be the same

spool awr-enq-hot-blocks.log

with waits as (
	select
		sh.instance_number
		, sh.snap_id
		, sh.sample_id
		, sh.blocking_session
		, sh.sql_id
		, chr(bitand(sh.p1,-16777216)/16777215)||
			chr(bitand(sh.p1, 16711680)/65535) lockname
		--, decode(bitand(sh.p1,65535),4,'ITL',6,'ROWLOCK','UNKNOWN') lockmode
		, bitand(sh.p1,65535) lockmode
		, sh.current_obj#
		, sh.current_file#
		, sh.current_block#
		--, count(*) * 10 waitcount -- only sampled every 10 seconds from gv$active_session_history
		, count(*) waitcount -- only sampled every 10 seconds from gv$active_session_history
		, max(time_waited) / power(10,6) time_waited
	from DBA_HIST_ACTIVE_SESS_HISTORY sh
	join dba_hist_snapshot s on s.snap_id = sh.snap_id
		and s.snap_id = sh.snap_id
		and s.instance_number = sh.instance_number
	where sh.blocking_session is not null
	--and sh.event_id = ( select event_id from v$event_name where name = 'enq: TX - row lock contention')
	and sh.event_id in ( select event_id from v$event_name where name like 'enq:%')
	and s.begin_interval_time between to_date('&&d_begin_date','&&d_date_format') and to_date('&&d_end_date','&&d_date_format')
	group by
		sh.instance_number
		, sh.snap_id
		, sh.sample_id
		, sh.blocking_session
		, sh.sql_id
		, sh.current_obj#
		, sh.current_file#
		, sh.current_block#
		, chr(bitand(sh.p1,-16777216)/16777215)||
			chr(bitand(sh.p1, 16711680)/65535)
		, bitand(sh.p1,65535)
) ,
blockers as (
	select distinct
		w.sql_id
		, w.snap_id
		, w.sample_id
		, w.blocking_session
		, w.lockname
		, case w.lockname
			when 'TX' then decode(w.lockmode, 0,'None', 1,'No Lock', 2,'Row-S (SS)', 3,'Row-X (SX)',4,'ITL', 5, 'S/Row-X (SRX)', 6,'ROWLOCK','UNKNOWN')
			when 'TM' then decode(w.lockmode, 0,'None', 1,'No Lock', 2,'Row-S (SS)', 3,'Row-X (SX)',4,'Share', 5, 'S/Row-X (SRX)', 6,'Exclusive','UNKNOWN')
			else decode(w.lockmode, 0,'None', 1,'No Lock', 2,'Row-S (SS)', 3,'Row-X (SX)',4,'Share', 5, 'S/Row-X (SRX)', 6,'Exclusive','UNKNOWN')
		end lockmode
		, w.current_obj#
		, w.current_file#
		, w.current_block#
		, waitcount
		, time_waited
	from waits w
	order by waitcount desc
),
rptdata as (
	select
		b.sql_id
		, b.current_obj#
		, b.current_file#
		, b.current_block#
		, b.lockname
		, b.lockmode
		-- we can sum() this, as the value retreived is max() from "waits" WITH clause
		, sum(time_waited) time_waited
		, sum(waitcount) wait_count
		--, count(*) itl_wait_count
	from blockers b
	where b.sql_id is not null
		-- exludes the -1 objects
		-- leaving them in, as there may be times that ASH has not cleared these values
		-- and the the session was waiting
		-- https://www.oracle.com/technetwork/database/manageability/ppt-active-session-history-129612.pdf
		--and b.current_obj# > 0
		and b.lockname != 'UL'	-- user defined locks
	group by b.sql_id
		, b.current_obj#
		, b.current_file#
		, b.current_block#
		, b.lockname
		, b.lockmode
	order by sql_id, wait_count desc
),
ranks as (
	select distinct
		sql_id
		, current_obj#
		, current_file#
		, current_block#
		, wait_count
		, time_waited
		, lockname
		, lockmode
		--, dense_rank() over (partition by sql_id order by time_waited desc ) sql_rank
		  -- no ties with row number
		, row_number() over (partition by sql_id order by time_waited desc  ) sql_rank
		, sum(time_waited) over (partition by sql_id) time_waited_sum
	from rptdata
	where wait_count >= &u_wait_count_min
		and time_waited > 0
)
select
	sql_id
	, time_waited_sum
	, wait_count
	, time_waited
	, lockname
	, lockmode
	, current_obj#
	, current_file#
	, current_block#
from ranks
where sql_rank <= 10
order by time_waited_sum desc, sql_id, sql_rank
/


spool off
ed awr-enq-hot-blocks.log

