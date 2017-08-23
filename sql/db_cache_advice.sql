
-- db_cache_advice.sql

-- see MetaLink Note:148511.1

set term off feed off 

col instance new_value instance noprint
select lower(instance_name) instance from v$instance;
set term on feed on

@clear_for_spool
spool $HOME/tmp/cache_advice_&&instance..csv

prompt NAME,SIZE_FOR_ESTIMATE,RAM_INCREASE,SIZE_FACTOR,READ_REDUCTION_FACTOR,ESTD_PHYSICAL_READS,PCT_PHYSREAD_DECREASE

with baseline as(
	select name pool_name, estd_physical_reads baseline_reads
	from v$db_cache_advice
	where size_factor = 1
)
select
	a.name
	||','|| a.block_size
	||','|| a.size_for_estimate
	||','|| round(a.size_for_estimate - ( a.size_for_estimate / a.size_factor ),0) 
	||','|| a.size_factor
	||','|| a.estd_physical_read_factor
	||','|| a.estd_physical_reads
	||','|| to_char(((b.baseline_reads/a.estd_physical_reads )-1) * 100,'999999')||'%' 
from v$db_cache_advice a, baseline b
where estd_physical_read_factor <= 1
and a.name = b.pool_name
order by name, block_size,size_factor
/

spool off

@clears

set line 120
set pagesize 60

col name head 'POOL NAME' format a10
col block_size format 999999999999	head 'BLOCK SIZE'
col size_for_estimate head 'CACHE SIZE|MEGABYTES' format 999,999
col ram_increase head 'RAM INCREASE|MEGABYTES' format 999,999
col size_factor head 'SIZE FACTOR' format 99.9999
col buffers_for_estimate head 'BUFFERS|FOR|ESTIMATE' head 999,999
col estd_physical_read_factor head 'READ REDUCTION|FACTOR' format 9.999
col estd_physical_reads head 'PHYS READS|ESTIMATE' format 999,999,999,999
col pct_physread_decrease head 'PHS READ PCT|DECREASE' format a12


with baseline as(
	select name pool_name, block_size, estd_physical_reads baseline_reads
	from v$db_cache_advice
	where size_factor = 1
)
select
	--a.id
	a.name
	, a.block_size
	--, a.advice_status
	, a.size_for_estimate
	, round(a.size_for_estimate - ( a.size_for_estimate / a.size_factor ),0) ram_increase
	, a.size_factor
	--, a.buffers_for_estimate
	, a.estd_physical_read_factor
	, a.estd_physical_reads
	, ltrim(to_char(((b.baseline_reads/a.estd_physical_reads )-1) * 100,'999,999'))||'%'  pct_physread_decrease 
from v$db_cache_advice a, baseline b
where estd_physical_read_factor <= 1
and a.name = b.pool_name
and a.block_size = b.block_size
order by name, block_size, size_factor
/

