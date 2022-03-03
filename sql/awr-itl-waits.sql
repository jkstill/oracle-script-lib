
-- awr-itl-waits.sql
-- Jared Still
-- 
-- jkstill@gmail.com

/*

As seen in an AWR report for 'Top Event P1/P2/P3 Values'

Event                      % Event P1, P2, P3 Values                 % Activity  Parameter 1 Parameter 2   Parameter 3
enq: TX - index contention 22.52   "1415053316","19529734","1548062" 1.65        name|mode   usn<<16|slot   sequence

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

-- d_date_format set by get_date_range.sql

col owner format a15
col object format a30
col object_type format a10
col index_name format a30
col table_name format a30
col lockmode format a20
col event_name format a40 head 'EVENT NAME'
col sql_id format a13
col instance_number format 9999 head 'INST'

col p1 format a10
col p2 format a10
col p3 format a10
col p1text format a25
col p2text format a30
col p3text format a25

set linesize 200 trimspool on
set pagesize 100

with waits as (
	select
		sh.instance_number
		, sh.snap_id
		, sh.sample_id
		, sh.blocking_session
		, sh.sql_id
		, decode(bitand(sh.p1,65535),4,'ITL',6,'ROWLOCK','UNKNOWN') lockmode
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
		, decode(bitand(sh.p1,65535),4,'ITL',6,'ROWLOCK','UNKNOWN')
) ,
blockers as (
select distinct 
	w.sql_id
	, w.snap_id
	, w.sample_id
	, w.blocking_session
	, lockmode
	--, waitcount
from waits w
where lockmode = 'ITL'
order by waitcount
)
select 
	h.sql_id
	, to_char(h.p1,'0XXXXXXX') p1
	, h.p1text
	, to_char(h.p2,'0XXXXXXX') p2
	, h.p2text
	, to_char(h.p3,'0XXXXXXX') p3
	, h.p3text
	, h.CURRENT_OBJ#
	, h.current_block#
from blockers b
join dba_hist_active_sess_history h
	on h.snap_id = b.snap_id
	--and h.sample_id = b.sample_id
	and h.session_id = b.blocking_session
	and h.sql_id = b.sql_id
order by h.sql_id, h.current_block#
/

