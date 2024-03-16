

set linesize 200 trimspool on
set pagesize 100

col sql_id format a13
col disk_reads format 99,999,999,999
col buffer_gets format 999,999,999,999
col ratio format 999.99


with data as (
	select 
		sql_id
		, sum(disk_reads) disk_reads
		, sum(cr_buffer_gets) + sum(cu_buffer_gets) buffer_gets
		, sum(output_rows) output_rows
	from v$sql_plan_statistics 
	group by sql_id
)
select 
	sql_id
	, disk_reads
	, buffer_gets
	, output_rows
	, to_char(case 
		when output_rows = 0 and buffer_gets = 0 then 0
		when output_rows = 0 and buffer_gets > 0 then 1
		when output_rows > 0 and buffer_gets = 0 then buffer_gets
		else buffer_gets / output_rows
	end, '999,999,999.99') ratio
from data
--where buffer_gets > 0
order by ratio
/
