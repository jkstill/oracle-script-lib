-- index-usage-awr.sql
-- jared still 2016-12-07
--  jkstill@gmail.com
--
-- not definitive, dependent on AWR data
-- the more AWR data, the better.
-- currently does not handle partition specific index info
-- eg. STATUS value is valid only for non-partitioned indexes

set linesize 300 trimspool on
set pagesize 60

col index_used_awr head 'IDX|USED|AWR' format a4
col index_type format a18
col owner format a15


col degree format a6
col leaf_blocks head 'LEAF|BLOCKS' format 99,999,999
col distinct_keys head 'DISTINCT|KEYS' format 9,999,999,999
col avg_leaf_blocks_per_key head 'AVG LEAF|BLOCKS|PER KEY' format 99,999,999
col avg_data_blocks_per_key head 'AVG DATA|BLOCKS|PER KEY' format 99,999,999
col clustering_factor head 'CLUSTER|FACTOR' format 9,999,999,999
col num_rows head 'NUM ROWS' format 9,9999,999,999

--spool index-usage-awr.txt

with users2chk as (
	select
		username
	from dba_users
	where default_tablespace not in ('SYSTEM','SYSAUX')
	and username not in ('SQLTXPLAIN')
),
indexes as (
	select owner, table_name, table_owner, index_name, join_index, partitioned, degree
		, leaf_blocks, distinct_keys
		, avg_leaf_blocks_per_key, avg_data_blocks_per_key
		, clustering_factor, num_rows ,
		case 
		when domidx_status is NULL then
			case 
			when funcidx_status is NULL then
				'BTREE - ' || status
			when funcidx_status = 'ENABLED' then
				'FUNCIDX - ENABLED'
			when funcidx_status = 'DISABLED' then
				'FUNCIDX - DISABLED'
			else 'UNKNOWN IDX Type(1)'
			end
		when domidx_status = 'VALID' then
			'DOMIDX - VALID'
		when domidx_status = 'IDXTYP_INVLD' then
			'DOMIDX - INVALID'
		else
			'UNKNOWN IDX Type(2)'
		end index_type
	from dba_indexes i
	join users2chk u on u.username = i.owner
),
indexes_used as (
	select distinct
		object_owner owner
		, object_name index_name
	from dba_hist_sql_plan sp
	join users2chk u on u.username = sp.object_owner
		and sp.object_type = 'INDEX'
)
select i.owner
	, t.table_name
	, t.blocks - nvl(t.empty_blocks,0) table_blocks
	, i.index_name
	, i.index_type
	, i.join_index
	, i.partitioned , i.degree
	, i.leaf_blocks, i.distinct_keys
	, i.avg_leaf_blocks_per_key, i.avg_data_blocks_per_key
	, i.clustering_factor, i.num_rows	
	, decode(iu.index_name,null,'NO','YES') index_used_awr
from indexes i
join dba_tables t	 on t.owner = i.table_owner
	and t.table_name = i.table_name
full outer join indexes_used iu on iu.owner = i.owner
	and iu.index_name = i.index_name
order by 1,2
/

--spool off
--ed index-usage-awr.txt


