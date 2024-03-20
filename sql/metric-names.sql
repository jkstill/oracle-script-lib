
-- metric-names.sql
-- Jared Still

col os_load format 999.99
col begin_time format a20
col metric_name format a45
col group_name format a35
col interval_seconds format 9999 head 'INTERVAL'
col group_id format 9999 head 'GRP|ID'
col metric_unit format a50

select m.metric_name
	, g.group_id
	, g.name group_name
	, g.interval_size / 100 interval_seconds
	, m.metric_unit
from v$metricname m
join v$metricgroup g on g.group_id = m.group_id
	and m.metric_name like '%'
order by m.group_id, m.metric_name
/

