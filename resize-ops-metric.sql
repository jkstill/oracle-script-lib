

-- resize-ops-metric.sql
-- look back through AWR for excessive resize operations
-- it may be that SGA needs an increase before ORA-4031 occurs

set linesize 200 trimspool on
set pagesize 60

col begin_interval_time format a30

-- number of standard deviations
define warning_threshold=3

-- days previous to check
define look_back_days=60

with pop as (
	--by hour
	--select begin_interval_time, count(*) resize_count
	-- by day
	select trunc(begin_interval_time) begin_interval_time
		, count(*) resize_count
	from dba_hist_memory_resize_ops m
	join dba_hist_snapshot s on s.snap_id = m.snap_id
	-- by hour
	--group by begin_interval_time
	-- by day
	group by trunc(begin_interval_time) 
	order by begin_interval_time
),
resize_stddev as(
	select distinct round(stddev(resize_count) over (),2) resize_stddev
	from pop
),
metrics as (
	select 
		p.begin_interval_time
		, p.resize_count
		, r.resize_stddev
		, round(p.resize_count / r.resize_stddev,1) resize_metric
	from pop p
	natural join resize_stddev r
	where p.begin_interval_time >= systimestamp - interval '&look_back_days' DAY
)
select begin_interval_time
	, resize_count
	, resize_stddev 
	, resize_metric
	, case
		when resize_metric >= &warning_threshold then
			'Warning'
		else
			'No Worries'
	end action
from metrics
order by 1
/
