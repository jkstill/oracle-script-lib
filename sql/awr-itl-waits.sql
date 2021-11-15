
-- awr_blocker_waits.sql
-- Jared Still
-- 
-- jkstill@gmail.com

-- find out what blocking sessions are waiting on

@clears

@get_date_range

-- d_date_format set by get_date_range.sql

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
	and sh.event_id = ( select event_id from v$event_name where name = 'enq: TX - row lock contention')
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

