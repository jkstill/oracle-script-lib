
-- blocker-tree.sql
-- Jared Still 2021-08-04
-- Purpose:  Find blocking chains in Oracle database
--           and display them in a tree format
-- updated the SQL used to define blockers and blocked sessions
-- added in lock_path, connect_by_root(sid) and sys_connect_by_path(sid,'/') to show the path of the blocking chain

set verify off

@get_date_range 

/*  

@blocker-tree  '2024-08-04 22:00:00' '2024-08-05 02:00:00' 

SID                  USERNAME             STATUS   PROGRAM                                            LOCK_PATH
-------------------- -------------------- -------- -------------------------------------------------- --------------------------------------------------
  483                SCOTT                Blocker  batchrun@batch.example.com (TNS V1-V3)          /483
    1146             SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1146
      1555           SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1146/1555
        1926         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1146/1555/1926
      1926           SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1146/1926
        1555         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1146/1926/1555
    1555             SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1555
      1146           SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1555/1146
        1926         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1555/1146/1926
      1926           SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1555/1926
        1146         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1555/1926/1146
    1921             SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921
      859            SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/859
        955          SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/859/955
          1144       SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/859/955/1144
        1144         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/859/1144
          955        SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/859/1144/955
      955            SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/955
        859          SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/955/859
          1144       SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/955/859/1144
        1144         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/955/1144
          859        SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/955/1144/859
      1144           SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1144
        859          SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1144/859
          955        SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1144/859/955
        955          SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1144/955
          859        SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1144/955/859
      1926           SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1926
        1146         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1926/1146
          1555       SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1926/1146/1555
        1555         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1926/1555
          1146       SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1921/1926/1555/1146
    1926             SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1926
      1146           SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1926/1146
        1555         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1926/1146/1555
      1555           SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1926/1555
        1146         SCOTT                Blocked  batchrun@batch.example.com (TNS V1-V3)          /483/1926/1555/1146
  859                SCOTT                Blocker  batchrun@batch.example.com (TNS V1-V3)          /859


*/


--def v_event_filter='enq: TX - row lock contention'
--def v_event_filter='enq: %'
def v_event_filter='%'

col sid  format a30
col username format a30
col status format a8
col program format a50
col lock_path format a50
col event format a40

set linesize 300 trimspool on

set pagesize 500

spool blocker-tree.log

with blocked as (
	select distinct
		 h.session_id sid
		, h.blocking_session blocking_sid
		, h.program
		, u.username
		, h.event
	from dba_hist_active_sess_history h
	join dba_hist_snapshot s on s.snap_id = h.snap_id
		and s.instance_number = h.instance_number
		and s.dbid = h.dbid
	join dba_users u on u.user_id = h.user_id
	where h.blocking_session is not null
	and s.begin_interval_time between to_date('&&d_begin_date','&&d_date_format') and to_date('&&d_end_date','&&d_date_format')
	and h.event like '&v_event_filter'
),
blocked_match as (
	select distinct
		h.instance_number
		, h.dbid
		, h.session_id sid
		, h.blocking_session blocking_sid
		, h.blocking_session_serial#
		, h.snap_id
		, h.sample_id
		, h.time_waited
		, h.program
		, u.username
	from dba_hist_active_sess_history h
	join dba_hist_snapshot s on s.snap_id = h.snap_id
		and s.instance_number = h.instance_number
		and s.dbid = h.dbid
	join dba_users u on u.user_id = h.user_id
	where h.blocking_session is not null
	and s.begin_interval_time between to_date('&&d_begin_date','&&d_date_format') and to_date('&&d_end_date','&&d_date_format')
	and h.event like '&v_event_filter'
),
blockers as (
	select distinct
		u.username
		, blkr.session_id sid
		, null blocking_sid
		, blkr.program
		, blkr.event
		--, blkr.time_waited
	from blocked_match b
	join dba_hist_active_sess_history blkr
		on b.snap_id = blkr.snap_id
		and b.dbid = blkr.dbid
		and b.instance_number = blkr.instance_number
		and b.sample_id = blkr.sample_id
		and b.blocking_sid = blkr.session_id
		and b.blocking_session_serial# = blkr.session_serial#
		--and blkr.blocking_session is null
	join dba_users u on u.user_id = blkr.user_id
),
all_data as (
	select username, sid, blocking_sid, 'Blocker' status, program, event
	from blockers
	union all
	select username, sid, blocking_sid, 'Blocked' status,  program, event
	from blocked
), 
rpt as (
	select
		lpad(' ',(level)*2,' ') || sid sid
		, username
		, status
		, program
		, event
		, level lock_depth
		, connect_by_isleaf isleaf
		, connect_by_root(sid) sid_root
		, sys_connect_by_path(sid,'/') lock_path
	from  all_data
	connect by nocycle blocking_sid = prior sid
	start with blocking_sid is null
)
select
	sid
	, username
	, status
	, program
	, event
	--, lock_depth
	--, isleaf
	, sid_root
	, lock_path
from rpt
--where sid_root = sid  -- blockers only
/

spool off

ed blocker-tree.log


