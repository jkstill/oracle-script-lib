select
        s.BEGIN_INTERVAL_TIME
        , value - lag(value,1) over (order by m.snap_id) diff
from dba_hist_snapshot s
join dba_hist_sys_time_model m
on m.snap_id = s.snap_id
where m.stat_name = 'connection management call elapsed time'
order by 1
/

