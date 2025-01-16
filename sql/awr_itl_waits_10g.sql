
-- awr_itl_waits_10g.sql.sql
-- show historic ITL  Waits
-- Jared Still
-- 
-- jkstill@gmail.com

@clears

@get_date_range

-- d_date_format set by get_date_range.sql

with waits as (
	select
		sh.instance_number
		, sh.sql_id
		, sh.blocking_session
		, sh.blocking_session_status blocker_status
		, bitand(sh.p1,65535) lockmode
	from DBA_HIST_ACTIVE_SESS_HISTORY sh
	join dba_hist_snapshot s on s.snap_id = sh.snap_id
   	and s.snap_id = sh.snap_id
   	and s.instance_number = sh.instance_number
	where sh.blocking_session is not null
	and sh.event_id = ( select event_id from v$event_name where name like 'enq: TX - row lock contention')
	and s.begin_interval_time between to_date('&&d_begin_date','&&d_date_format') and to_date('&&d_end_date','&&d_date_format')
)
select
	w.sql_id
	, w.blocker_status
	, decode(w.lockmode, 4,'ITL',6,'ROWLOCK','UNKNOWN') lockmode
	, count(*) * 10 waitcount -- only sampled every 10 seconds from gv$active_session_history
from waits w
where lockmode = 4
group by  w.sql_id, w.blocker_status, w.lockmode
order by waitcount
/

