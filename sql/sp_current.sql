
-- sp_current.sql
-- get data associated with latest snapshot
-- from some statspack table

--select * 
--from perfstat.stats$sql_plan
--where snap_id = ( select max(snap_id) from perfstat.stats$snapshot)
--/

select * 
from perfstat.stats$sqltext
where last_snap_id = ( select max(snap_id) from perfstat.stats$snapshot)
/
