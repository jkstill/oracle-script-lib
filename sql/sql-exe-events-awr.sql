
-- sql-exe-events-awr.sql
-- Jared Still	 jkstill@gmail.com
--	 2018

@clears

col u_sql_id new_value u_sql_id noprint
var v_sql_id varchar2(13) 

set linesize 200 trimspool on
set pagesize 100

col sample_time format a28

prompt
prompt SQL_ID: 
prompt

set term off feed off verify off

select '&1' u_sql_id from dual;

set term on feed on

exec :v_sql_id := '&u_sql_id'

@get_date_range

break on session_id  skip 1

with blocked as (
	select distinct h.instance_number, h.dbid, h.blocking_session, h.blocking_session_serial#,  h.snap_id, h.sample_id, h.sql_id
	from dba_hist_active_sess_history h
	join dba_hist_snapshot s on s.snap_id = h.snap_id
		and s.instance_number = h.instance_number
		and s.dbid = h.dbid
	where h.blocking_session is not null
	and s.begin_interval_time between to_date('&&d_begin_date','&&d_date_format') and to_date('&&d_end_date','&&d_date_format')
	and h.event like '&v_event_filter'
),
blockers as (
	select distinct
		max(blkr.snap_id) over (partition by blkr.session_id, blkr.session_serial#, blkr.event) snap_id
		, max(blkr.sample_id) over (partition by blkr.session_id, blkr.session_serial#, blkr.event) sample_id
		, max(blkr.sample_time) over (partition by blkr.session_id, blkr.session_serial#, blkr.event) sample_time
		, count(blkr.sample_time) over (partition by blkr.session_id, blkr.session_serial#, blkr.event) event_count
		, b.sql_id
		, blkr.session_id
		, blkr.session_serial#
		, blkr.session_state
		-- NULL for top level blockers
		, blkr.blocking_session
		, blkr.event
		--, blkr.time_waited
	from blocked b
	join dba_hist_active_sess_history blkr
		on b.snap_id = blkr.snap_id
		and b.dbid = blkr.dbid
		and b.instance_number = blkr.instance_number
		and b.sample_id = blkr.sample_id
		and b.blocking_session = blkr.session_id
		and b.blocking_session_serial# = blkr.session_serial#
		--and blkr.blocking_session is null
)
select *
from blockers
order by sample_id, event, event_count
/

undef &1

