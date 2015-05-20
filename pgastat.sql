
/*

over allocation count
maximum PGA allocated
aggregate PGA target parameter
global memory bound

see oracle docs on v$pgastat

*/

@clears

col pga_target format 99,999,999,999
col max_pga format 99,999,999,999
col over_alloc_count format 99,999,999
col mem_bound format 99,999,999,999

with pga_target as (
	select inst_id, value pga_target
	from gv$pgastat
	where name = 'aggregate PGA target parameter'
),
over_alloc as (
	select inst_id, value over_alloc_count
	from gv$pgastat
	where name = 'over allocation count'
),
max_pga as (
	select inst_id, value max_pga
	from gv$pgastat
	where name = 'maximum PGA allocated'
),
global_mem_bound as (
	select inst_id, value mem_bound
	from gv$pgastat
	where name = 'global memory bound'
)
select 
	t.inst_id
	, t.pga_target
	, m.max_pga
	, o.over_alloc_count
	, g.mem_bound
from pga_target t
join over_alloc o on o.inst_id = t.inst_id
join max_pga m on m.inst_id = t.inst_id
join global_mem_bound g on g.inst_id = t.inst_id
order by inst_id
/


