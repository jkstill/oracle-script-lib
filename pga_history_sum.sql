
-- pga_history_sum.sql
-- summarize pga usage for all statspack entries


@pgacols

select name, max(value) value
from (
select
	distinct
	max(s.snap_time) over ( partition by to_char(snap_time,'YYYY/WW')) snap_time
	, p.name
	, avg(p.value) over ( partition by to_char(snap_time,'YYYYWW'), p.name ) value
from stats$pgastat p, stats$snapshot s
where p.snap_id = s.snap_id
) s
group by name
order by 1,2
/

