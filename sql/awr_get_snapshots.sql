

-- awr_get_snapshots.sql

set linesize 200 trimspool on
set pagesize 1000
column con_id format 999 heading "Con|ID"
column dbid format 999999999999 heading "DB|ID"
column instance_number format 999 heading "Instance|#"
column snap_id format 9999999 heading "Snap|ID"
column begin_interval_time format a30 heading "Begin|Interval|Time"
column end_interval_time format a30 heading "End|Interval|Time"

select con_id, dbid, instance_number, snap_id, begin_interval_time, end_interval_time
from cdb_hist_snapshot
order by 1,2,3,4
/

