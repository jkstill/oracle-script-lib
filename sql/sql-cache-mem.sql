
-- sql-workarea-memory.sql
-- Jared Still 2022

set pagesize 100
set linesize 200 trimspool off
set tab off

col sql_id format a13 head 'SQL ID'
col min_memory_used format 99,999,999,999 head 'MIN|MEMORY|USED'
col max_memory_used format 99,999,999,999 head 'MAX|MEMORY|USED'
col avg_max_memory_used_sum format 99,999,999 head 'AVG MAX|MEMORY|USED'

with workarea as (
	select 
		sql_id
		--, child_number
		--, estimated_optimal_size
		--, estimated_onepass_size
		, min(last_memory_used) min_memory_used
		, max(last_memory_used) max_memory_used
	from v$sql_workarea
	where last_memory_used != 0
	group by sql_id
)
select
	sql_id
	, min_memory_used
	, max_memory_used
	, 0 avg_max_memory_used_sum
from workarea
union all
select 'ALL SQL' sqlid
	, sum(min_memory_used) min_memory_used_sum
	, sum(max_memory_used) max_memory_used_sum
	, avg(max_memory_used) avg_max_memory_used_sum
from workarea
order by 3
/
