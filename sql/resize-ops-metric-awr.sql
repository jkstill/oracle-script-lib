

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

-- look back how far?
-- further back than 99 days requires using a WEEK or MONTH interval rather than DAY
-- interval '100' DAY will cause ORA-01873 'precision too small'
define look_back_units='DAY'
define look_back_count=60
--define look_back_units='MONTH'
--define look_back_count=18

with pop as (
	--by hour
	select begin_interval_time
		, s.instance_number
	-- by day
	--select trunc(begin_interval_time) begin_interval_time
		, count(*) resize_count
	from dba_hist_memory_resize_ops m
	join dba_hist_snapshot s on s.snap_id = m.snap_id
		and s.dbid = m.dbid
		and s.instance_number = m.instance_number
	-- by hour
	group by begin_interval_time
		, s.instance_number
	-- by day
	--group by trunc(begin_interval_time) 
	order by begin_interval_time
),
resize_stddev as(
	select distinct round(stddev(resize_count) over (),2) resize_stddev
	from pop
),
metrics as (
	select 
		to_char(p.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') begin_interval_time
		, p.instance_number
		, p.resize_count
		, r.resize_stddev
		-- set resize metric to 1 if r.resize_stddev is 0
		, round(p.resize_count / decode(r.resize_stddev,0,p.resize_count,r.resize_stddev),1) resize_metric
	from pop p
	natural join resize_stddev r
	where p.begin_interval_time >= systimestamp - interval '&look_back_count' &look_back_units
)
select begin_interval_time, instance_number
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
