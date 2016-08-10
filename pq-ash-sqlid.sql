
-- pq-ash-sqlid.sql
-- aggregate PQ per sqlid and time

set linesize 200 trimspool on
set pagesize 60
col sample_time format a35

select sample_id, sql_id, max(sample_time) sample_time , count(qc_session_id) pq_slaves
from v$active_session_history
where qc_Session_id is not null
group by sample_id, sql_id
having count(qc_session_id) > 1
order by sample_id, sql_id
/
