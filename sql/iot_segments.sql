
set linesize 200 pagesize 60

@@columns

with idxsegs as (
	select i.owner, i.index_name, t.table_name
	from dba_indexes i
	join dba_tables t on t.table_name = i.table_name
		and t.owner = i.table_owner
	where iot_type = 'IOT'
)
select s.owner, xs.table_name, xs.index_name, s.bytes
from dba_segments s
join idxsegs xs on xs.owner = s.owner
	and xs.index_name = s.segment_name
order by owner, table_name, index_name
/
