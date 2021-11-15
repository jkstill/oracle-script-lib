
-- stale-stats.sql
-- check for stale statistics
-- Jared Still -  2017
--  jkstill@gmail.com
-- includes partitions and subpartitions
-- table_name == table_name.partition_name.subpartition_name
-- index_name == index_name.partition_name.subpartition_name

col owner format a30
col table_name format a92
col index_name format a92
col last_analy format a19 
col stale_stats format a3 head 'STL'
col stattype_locked head lckd format a4
col num_rows format 999,999,999
col blocks format 99,999,999
col clustering_factor format 99,990.90 head 'CLSTR FCTR'

set linesize 300 trimspool on
set pagesize 100
set echo off

var v_exclude_sys varchar2(3)

exec :v_exclude_sys := 'YES'
exec :v_exclude_sys := 'NO'

spool stale-stats.txt

with excluded_schemas as (
	select name schema_to_exclude
	from system.LOGSTDBY$SKIP_SUPPORT
	where action = 0
		and :v_exclude_sys = 'YES'
	order by schema_to_exclude
)
select 
	owner
	, table_name
		|| decode(partition_name, null,'','.' || partition_name)
		|| decode(subpartition_name, null,'','.' || subpartition_name)
		as table_name
	, null index_name
	, num_rows
	, blocks
	, null clustering_factor 
	, stattype_locked
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
	, stale_stats
from dba_tab_statistics s
where stale_stats='YES'
	and owner not in (select schema_to_exclude from excluded_schemas)
union all
select 
	owner
	, table_name 
	, index_name 
		|| decode(partition_name, null,'','.' || partition_name)
		|| decode(subpartition_name, null,'','.' || subpartition_name)
		as index_name
	, num_rows
	, leaf_blocks blocks
	, clustering_factor 
	, stattype_locked
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
	, stale_stats
from dba_ind_statistics s
where stale_stats='YES'
	and owner not in (select schema_to_exclude from excluded_schemas)
--order by last_analyzed, owner, table_name, index_name nulls first
order by table_name, index_name nulls first
/

spool off

ed stale-stats.txt

