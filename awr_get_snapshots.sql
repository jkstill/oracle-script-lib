

-- awr_get_snapshots.sql

select instance_number, snap_id, begin_interval_time, end_interval_time
from dba_hist_snapshot
where trunc(begin_interval_time,'DD') between to_date('2012-06-27','yyyy-mm-dd') and to_date('2012-06-28','yyyy-mm-dd')
--where rownum < 10
order by 1,2
/

