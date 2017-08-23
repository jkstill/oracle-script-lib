
-- pq-awr-sqlid.sql
-- aggregate PQ per sqlid and time

set linesize 200 trimspool on
set pagesize 60
col sample_time format a35
col begin_interval_time format a35


select h.snap_id
	, s.begin_interval_time
	, h.sample_id
	, h.sql_id
	, max(h.sample_time) sample_time 
	, count(h.qc_session_id) pq_slaves
from dba_hist_active_sess_history h
	join dba_hist_snapshot s on s.snap_id = h.snap_id
where h.qc_session_id is not null
group by s.begin_interval_time,h.snap_id,h.sample_id, h.sql_id
having count(h.qc_session_id) > 1
order by h.snap_id,h.sample_id, h.sql_id
/

