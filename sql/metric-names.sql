
col os_load format 999.99
col begin_time format a20
col metric_name format a45
col group_name format a35
col interval_seconds format 9999 head 'INTERVAL'
col group_id format 9999 head 'GRP|ID'

select m.metric_name
	, g.group_id
	, g.name group_name
	, g.interval_size / 100 interval_seconds
from v$metricname m
join v$metricgroup g on g.group_id = m.group_id
order by m.metric_name, m.group_id
/
