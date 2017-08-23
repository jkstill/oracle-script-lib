
-- resize-ops-metric.sql
-- look back through AWR for excessive resize operations
-- it may be that SGA needs an increase before ORA-4031 occurs

-- when AMM/ASMM is used SGA memory is divided into pools
-- sometimes Oracle will throw ORA-4031 even though there is sufficient memory in another subpool
-- see mem-subpool-mgt.sql


set linesize 200 trimspool on
set pagesize 60

col begin_interval_time format a30

-- number of standard deviations
define warning_threshold=3

-- days previous to check
define look_back_days=60

with pop as (
	--by hour
	select start_time begin_interval_time
		, inst_id
		, count(*) resize_count
	from GV$MEMORY_RESIZE_OPS m
	-- by hour
	group by start_time
		, inst_id
	-- by day
	--group by trunc(begin_interval_time)
	order by start_time
),
resize_stddev as(
	select distinct round(stddev(resize_count) over (),2) resize_stddev
	from pop
),
metrics as (
	select
		to_char(p.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') begin_interval_time
		, p.inst_id
		, p.resize_count
		, r.resize_stddev
		-- set resize metric to 1 if r.resize_stddev is 0
		, round(p.resize_count / decode(r.resize_stddev,0,p.resize_count,r.resize_stddev),1) resize_metric
	from pop p
	natural join resize_stddev r
	where p.begin_interval_time >= systimestamp - interval '&look_back_days' DAY
)
select begin_interval_time, inst_id
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
order by 2,1
/
