
-- awr_display_baselines.sql

set linesize 200 trimspool on
set pagesize 60
set echo off pause off term on head on 

col baseline_name format a50
col baseline_type format a15 head 'BASELINE TYPE'
col start_snap_id format 99999999 head 'START|SNAP ID'
col end_snap_id format 99999999 head 'END|SNAP ID'
col start_snap_time format a20
col end_snap_time format a20
col expiration format a20
col creation_time format a20

select
	--dbid
	--, baseline_id
	baseline_name
	, baseline_type
	, start_snap_id
	, to_char(start_snap_time,'yyyy-mm-dd hh24:mi:ss') start_snap_time
	, end_snap_id
	, to_char(end_snap_time,'yyyy-mm-dd hh24:mi:ss') end_snap_time
	--, moving_window_size
	, to_char(creation_time,'yyyy-mm-dd hh24:mi:ss') creation_time
	, to_char(creation_time+expiration,'yyyy-mm-dd hh24:mi:ss') expiration
	--, template_name
	--, last_time_computed
	--, con_id
from dba_hist_baseline
order by creation_time
/
