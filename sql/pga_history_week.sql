
-- pga_history_week.sql
-- summarize pga usage by week from statspack

@pgacols

break on snap_time skip 1

select
	distinct
	--to_char(max(to_date(to_char(s.snap_time,'mm/dd/yyyy'),'mm/dd/yyyy')) over ( partition by to_char(snap_time,'YYYY/WW')),'YYYY/WW') snap_time
	to_char(max(s.snap_time) over ( partition by to_char(snap_time,'YYYY/WW')),'YYYY/WW') snap_time
	, p.name
	, avg(p.value) over ( partition by to_char(snap_time,'YYYYWW'), p.name ) value
from stats$pgastat p, stats$snapshot s
where p.snap_id = s.snap_id
order by 1,2
/

