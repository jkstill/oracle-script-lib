
-- sp_top_sql_io.sql
-- Jared Still - 
-- 2017-09-07  jkstill@gmail.com

-- get top 10 SQL statements based on disk reads

with sqlreads as (
	select distinct sql_id, snap_id,  instance_number, disk_reads - lag(disk_reads) over (partition by sql_id order by snap_id) disk_reads
	from perfstat.stats$sql_summary
	order by 4 desc nulls last
)
select *
from sqlreads
where rownum <= 10
/

