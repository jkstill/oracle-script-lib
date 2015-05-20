
-- sp_recent.sql
-- get the 10 most recent snapshots

select snap_id, snap_time, snap_level, executions_th
from 
(
	select *
	from perfstat.stats$snapshot
	order by snap_id desc
)
where rownum <= 10
order by snap_id
/

