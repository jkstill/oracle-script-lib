
-- ash-cpu-hist.sql
-- cross tab of cpu history
-- only useful in 12c+ as previous versions did not save the stats
-- 2015-11-18 Jared Still
-- 
-- jkstill@gmail.com

set pagesize 60
set linesize 200 trimspool on

col db_cpu_per_sec  format 9999.999 null 0
col host_cpu_per_sec  format 9999.999 null 0
col resmgr_cpu_wait_time format 9999.999 null 0

-- for csv

@clear_for_spool

spool cpu-hist.csv

prompt  END_INTERVAL_TIME,DB_CPU_PER_SEC,HOST_CPU_PER_SEC,RESMGR_CPU_WAIT_TIME

with data as (
select to_char(s.end_interval_time,'yyyy-mm-dd hh24:mi:ss') end_interval_time
	,metric_name
	, average
	--, metric_unit -- all are centiseconds 
from dba_hist_sysmetric_summary h
join dba_hist_snapshot s on s.snap_id = h.snap_id
where  h.metric_id in (
	select metric_id
	from dba_hist_metric_name
	where metric_name in (
		'CPU Usage Per Sec'
		,'Host CPU Usage Per Sec'
		,'CPU Wait Time' -- when resource managers causes wait for CPU
	)
)
)
select 
	-- end_interval_time
	-- , db_cpu_per_sec
	-- , host_cpu_per_sec
	-- , resmgr_cpu_wait_time
	end_interval_time
	|| ',' || nvl(db_cpu_per_sec,0)
	|| ',' || nvl(host_cpu_per_sec,0)
	|| ',' || nvl(resmgr_cpu_wait_time,0)
from data
pivot (
	max(average)
	for metric_name in (
		'CPU Usage Per Sec' as db_cpu_per_sec
		, 'Host CPU Usage Per Sec' as host_cpu_per_sec
		, 'CPU Wait Time' as resmgr_cpu_wait_time
	)
)
order by 1
/

spool off

@clears

