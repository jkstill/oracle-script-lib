
-- awr-itl-wait-hot-blocks.sql
-- Jared Still
--
-- jkstill@gmail.com

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

*/


@clears

set pagesize 100
set linesize 200 trimspool on

col sql_id format a13 head 'SQL ID'
col current_obj#	format 999999999 head 'Obj#'
col current_file# format 999999 head 'File#'
col current_block# format 9999999999 head 'Block#'
col itl_wait_count format 99,999,999 head 'ITL Wait|Count'
col sql_rank format 9999999 head 'SQL Rank'

-- call with something like this
-- @awr-itl-wait-hot-blocks '2023-10-15 00:00:00' '2023-11-04 00:00:00'

@get_date_range

clear break
break on sql_id skip 1

with waits as (
	select
		sh.instance_number
		, sh.snap_id
		, sh.sample_id
		, sh.blocking_session
		, sh.sql_id
		, decode(bitand(sh.p1,65535),4,'ITL',6,'ROWLOCK','UNKNOWN') lockmode
		, sh.current_obj#
		, sh.current_file#
		, sh.current_block#
		, count(*) * 10 waitcount -- only sampled every 10 seconds from gv$active_session_history
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
		, decode(bitand(sh.p1,65535),4,'ITL',6,'ROWLOCK','UNKNOWN')
) ,
blockers as (
select distinct
	w.sql_id
	, w.snap_id
	, w.sample_id
	, w.blocking_session
	, lockmode
	, w.current_obj#
	, w.current_file#
	, w.current_block#
from waits w
where lockmode = 'ITL'
order by waitcount desc
),
rptdata as (
	select
		b.sql_id
		, b.current_obj#
		, b.current_file#
		, b.current_block#
		, count(*) itl_wait_count
	from blockers b
	where b.sql_id is not null
		and b.current_obj# > 0
	group by b.sql_id
		, b.current_obj#
		, b.current_file#
		, b.current_block#
	order by sql_id, itl_wait_count desc
),
ranks as (
	select
		sql_id
		, current_obj#
		, current_file#
		, current_block#
		, itl_wait_count
		--, dense_rank() over (partition by sql_id order by itl_wait_count desc ) sql_rank
		  -- no ties with row number
		  , row_number() over (partition by sql_id order by itl_wait_count desc	 ) sql_rank
	from rptdata
)
select
	sql_id
	, itl_wait_count
	, current_obj#
	, current_file#
	, current_block#
from ranks
where sql_rank <= 10
--and sql_id = 'some-sql-id'
order by sql_id, sql_rank
/

