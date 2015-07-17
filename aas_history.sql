
col value format 999999
col end_interval_time forma a25
set pagesize 60

select to_char(s.end_interval_time,'yyyy-mm-dd hh24:mi:ss.ff') end_interval_time, h.value
from dba_hist_sysmetric_history h
join dba_hist_snapshot s on s.snap_id = h.snap_id
where metric_name = 'Average Active Sessions'
order by 1,2
/
