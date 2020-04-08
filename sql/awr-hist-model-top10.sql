
-- hist-model-top10.sql
-- show the top 10 periods of DB Time

set linesize 200
set pagesize 100

col begin_interval_time format a25

set num 16

with data as (
	select 
		m. snap_id
		, m.stat_name
		, m.instance_number
		, sum(m.value) value
	from DBA_HIST_SYS_TIME_MODEL m
	where m.stat_name in ('DB CPU', 'DB time')
	group by
		m. snap_id
		, m.stat_name
		, m.instance_number
	order by m.snap_id, m.instance_number
),
metrics as (
	select
		m.snap_id
		, s.begin_interval_time
		, m.instance_number
		, m.value - lag(m.value,1) over (partition by m.instance_number order by m.snap_id) value 
	from data m
	join dba_hist_snapshot s on s.snap_id = m.snap_id
		and s.instance_number = m.instance_number
	order by value desc nulls last
)
select 
	m.snap_id
	, m.begin_interval_time
	, m.instance_number
	, m.value
from metrics m
where rownum <= 10
/
