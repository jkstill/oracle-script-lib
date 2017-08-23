

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
col begin_interval_time format a30 head 'SNAPSHOT START TIME'

set line 200 trimspool on
set pagesize 60

with pga_target as (
	select snap_id, instance_number, value pga_target
	from  dba_hist_pgastat
	where name = 'aggregate PGA target parameter'
),
over_alloc as (
	select snap_id, instance_number, value over_alloc_count
	from dba_hist_pgastat
	where name = 'over allocation count'
),
max_pga as (
	select snap_id, instance_number, value max_pga
	from dba_hist_pgastat
	where name = 'maximum PGA allocated'
),
global_mem_bound as (
	select snap_id, instance_number, value mem_bound
	from dba_hist_pgastat
	where name = 'global memory bound'
)
select
	s.begin_interval_time
	, t.instance_number
	, t.pga_target
	, m.max_pga
	, o.over_alloc_count
	, g.mem_bound
	, case 
		when g.mem_bound < power(2,20) then 'Mem too low' -- see v$pgastat docs
		else 'Mem ok'
	end memchk
from pga_target t
join over_alloc o on o.instance_number = t.instance_number
	and o.snap_id = t.snap_id
join max_pga m on m.instance_number = t.instance_number
	and m.snap_id = t.snap_id
join global_mem_bound g on g.instance_number = t.instance_number
	and g.snap_id = t.snap_id
join dba_hist_snapshot s on s.snap_id = t.snap_id
	and s.instance_number = t.instance_number
order by s.snap_id, t.instance_number
/
