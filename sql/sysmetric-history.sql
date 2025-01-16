-- sysmetric-history.sql
-- Jared Still - 2015-10-21
-- 
-- jkstill@gmail.com

col vinstance new_value vinstance
select lower(instance_name) vinstance from v$instance;

@clear_for_spool
set line 400 trimspool on

set term off

spool sysmetric-hist-&&vinstance..csv

prompt END_INTERVAL_TIME,AAS,SINGLE_BLOCK_READ_LATENCY,IO_MB_PER_SEC,IO_REQ_PER_SEC,NET_VOLUME_PER_SEC,PHYS_READS_PER_SEC,PHYS_WRITES_PER_SEC,REDO_PER_SEC

with metrics as (
	select end_interval_time
		,metric_name
		--, metric_unit
		, value
	from dba_hist_sysmetric_history m
	join dba_hist_snapshot s on s.snap_id = m.snap_id
	-- These are all Metrics available:
	where  metric_name in (
		'Average Active Sessions'
		, 'Average Synchronous Single-Block Read Latency'
		--, 'Current Open Cursors Count'
		--, 'DB Block Changes Per Txn'
		--, 'Enqueue Requests Per Txn'
		--, 'Executions Per Sec'
		, 'I/O Megabytes per Second'
		, 'I/O Requests per Second'
		--, 'Logical Reads Per Txn'
		--, 'Logons Per Sec'
		, 'Network Traffic Volume Per Sec'
		--, 'PGA Cache Hit %'
		, 'Physical Reads Per Sec'
		--, 'Physical Reads Per Txn'
		, 'Physical Writes Per Sec'
		, 'Redo Generated Per Sec'
		--, 'Redo Generated Per Txn'
		--, 'Response Time Per Txn'
		--, 'SQL Service Response Time'
		--, 'Total Parse Count Per Txn'
		--, 'User Calls Per Sec'
		--, 'User Transaction Per Sec'
	)
	--and rownum <= 1000
	order by m.snap_id
)
select
/*
	to_char(end_interval_time,'yyyy-mm-dd hh24:mi:ss') end_interval_time
	, aas
	-- reported in ms - convert to seconds
	, single_block_read_latency / 1000 single_block_read_latency
	, io_mb_per_sec
	, io_req_per_sec
	, net_volume_per_sec
	, phys_reads_per_sec
	, phys_writes_per_sec
	, redo_per_sec
*/
	to_char(end_interval_time,'yyyy-mm-dd hh24:mi:ss')
	|| ',' || aas
	|| ',' || (single_block_read_latency / 1000)
	|| ',' || io_mb_per_sec
	|| ',' || io_req_per_sec
	|| ',' || net_volume_per_sec
	|| ',' || phys_reads_per_sec
	|| ',' || phys_writes_per_sec
	|| ',' || redo_per_sec
from (
	select 
		end_interval_time
		, metric_name
		, value
	from metrics
)
pivot (
	max(value)
	for metric_name in (
		'Average Active Sessions' as aas
		, 'Average Synchronous Single-Block Read Latency' as single_block_read_latency
		, 'I/O Megabytes per Second' as io_mb_per_sec
		, 'I/O Requests per Second' as io_req_per_sec
		, 'Network Traffic Volume Per Sec' as net_volume_per_sec
		, 'Physical Reads Per Sec' as phys_reads_per_sec
		, 'Physical Writes Per Sec' as phys_writes_per_sec
		, 'Redo Generated Per Sec' as redo_per_sec
	)
)
order by end_interval_time
/

spool off
set term on

@clears
