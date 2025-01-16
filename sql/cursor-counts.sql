

-- cursor-counts.sql
-- simple count of shared cursors
--
-- Jared Still 2017-11-08   jkstill@gmail.com


select distinct sql_id
	, count(child_number) over (partition by sql_id order by sql_id) child_count 
from v$sql_shared_cursor
order by 2
/
