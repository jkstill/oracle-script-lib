
-- awr-blocker-waits.sql
-- like ash-blocker-waits.sql, but for AWR
-- show historic blockers and SQL_ID
-- 
-- 2017-01-07
--
-- the blocking session may not be in AWR
-- look for rows with NULL blocking_session value, as they are top level blockers
-- we want to know what those are waiting on
-- if top level blockers are waiting on an idle event they may not appear in AWR

clear col 
clear break
ttitle off
btitle off

@get_date_range

col v_event_filter new_value v_event_filter noprint

prompt
prompt Filter Blockers on event? (wildcard ok)
prompt
prompt

set feed off term off verify off
select '&3' v_event_filter from dual;
set feed on term on 

set echo off heading on feedback on
set linesize 200 trimspool on
set pagesize 60

set tab off
col instance_number format 9999 head 'INST'
col event_count format 9,999,999 head 'EVENT|COUNT'
col seession_serial$ format 999999 head 'SESSION|SERIAL#'
col blocking_sql_id format a12 head 'BLOCKING|SQL_ID'
col session_id format 999999 head 'SID'
col blocking_session format 999999 head 'BLOCKING|SID'
col event format a40 head 'EVENT'
col session_state format a12 head 'SESSION|STATE'
col time_waited format 999,999.99 head 'TIME|WAITED|SECONDS'
col sample_time format a25 head 'SAMPLE TIME'


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
		max(blkr.snap_id) over (partition by blkr.instance_number, blkr.session_id, blkr.session_serial#, blkr.event) snap_id
		, max(blkr.sample_id) over (partition by blkr.instance_number, blkr.session_id, blkr.session_serial#, blkr.event) sample_id
		, max(blkr.sample_time) over (partition by blkr.instance_number, blkr.session_id, blkr.session_serial#, blkr.event) sample_time
		, count(blkr.sample_time) over (partition by blkr.instance_number, blkr.session_id, blkr.session_serial#, blkr.event) event_count
		, blkr.instance_number
		, b.sql_id
		, blkr.session_id
		, blkr.session_serial#
		, blkr.blocking_session
		, blkr.session_state
		-- NULL for top level blockers
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

