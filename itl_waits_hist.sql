
col begin_interval_time format a30

set linesize 200 trimspool on
set pagesize 60

select 
	s.begin_interval_time
	--, d.instance_number
	, sum(itl_waits_delta) itl_waits_delta
	, sum(row_lock_waits_delta) row_lock_waits_delta
from dba_hist_seg_stat d
join dba_hist_snapshot s on s.snap_id = d.snap_id
	and s.instance_number = d.instance_number
group by s.begin_interval_time
order by s.begin_interval_time
/
