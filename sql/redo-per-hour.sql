-- redo-per-hour.sql

set linesize 200 trimspool on
set pagesize 100

col bytes format 999,999,999,999

with data as (
	select
		--completion_time
		to_char(completion_time, 'yyyy-mm-dd hh24') || ':00:00' hour
		, sum(blocks*block_size) bytes
	from v$archived_log
	group by to_char(completion_time, 'yyyy-mm-dd hh24') || ':00:00'
)
select hour, bytes
from (
	select hour, bytes
	from data
	order by 1
)
union all 
select '==== aggregates ===', 0 from dual
union all
select 'AVG' , avg(bytes) bytes
from data
union all
select 'MAX' , max(bytes) bytes
from data
union all
select 'MIN' , min(bytes) bytes
from data
/

