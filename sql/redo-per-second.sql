
-- redo-per-second.sql
-- Jared Still 2022
-- as per sysmetric_history
-- aggregates are per AWR snapshot interval, and min/avg/max chosen

col min_redo_per_second format 999,999,999
col avg_redo_per_second format 999,999,999
col max_redo_per_second format 999,999,999

with metrics as (
	select end_interval_time ,metric_name , value
	from dba_hist_sysmetric_history m
	join dba_hist_snapshot s on s.snap_id = m.snap_id
	where  metric_name = 'Redo Generated Per Sec'
	order by m.snap_id
)
select
   --end_interval_time, 
	min(redo_per_sec) min_redo_per_second
	, avg(redo_per_sec) avg_redo_per_second
	, max(redo_per_sec) max_redo_per_second
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
		'Redo Generated Per Sec' as redo_per_sec
	)
)
/
