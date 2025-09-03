
-- tab-info.sql
-- Jared Still
-- show info on tables - still wip
-- todo: partitions, subpartitions, automate input

-- avg_rows_per_block will be 0 if the blocks and avg_row_len are unknown or 0


set verify off tab off echo off pause off
set linesize 200 trimspool on
set pagesize 100

col u_table_owner new_value u_table_owner noprint
col u_table_to_check new_value u_table_to_check noprint

prompt table_owner:
set feed off term off
select '&1' u_table_owner from dual;
set feed on term on

prompt table:
set feed off term off
select '&2' u_table_to_check from dual;
set feed on term on


col owner format a20
col object_name format a30
col ini_trans format 999 head 'ITL'
col avg_row_len format 999,999 head 'Average|Row Length'
col avg_rows_per_block format 9999 head 'Avg Rows|Per Block'
col block_size format 99999 head 'Block|Size'
col last_analyzed format a12 head 'Last|Analyzed'
col num_rows format 99,999,999,999 head 'Num Rows'
col blocks format 999,999,999 head 'Blocks'
col tablespace_name format a20


select
	t.owner
	, 'TABLE' object_type
	, ts.tablespace_name
	, t.table_name object_name
	, ts.block_Size
	, t.ini_trans
	, nvl(to_char(last_analyzed,'yyyy-mm-dd'),'NA') last_analyzed
	, nvl(t.num_rows,0) num_rows
	, nvl(t.blocks,0) blocks
	, nvl(t.avg_row_len,0) avg_row_len
	,	case when nvl(t.blocks,1) /nvl(t.num_rows,1) = 1
		then 0
		else	nvl(t.blocks,1) /nvl(t.num_rows,1)
		end avg_rows_per_block
from dba_tables t
join dba_tablespaces ts on ts.tablespace_name = t.tablespace_name
where t.owner = '&u_table_owner'
and t.table_name = '&u_table_to_check'
union all
select
	t.owner
	, 'INDEX' object_type
	, ts.tablespace_name
	, t.index_name object_name
	, ts.block_Size
	, t.ini_trans
	, nvl(to_char(last_analyzed,'yyyy-mm-dd'),'NA') last_analyzed
	, nvl(t.num_rows,0) num_rows
	, nvl(t.leaf_blocks,0) blocks
	,
		case when nvl(t.num_rows,1) / nvl(t.leaf_blocks,1) = 1
		then 0
		else t.num_rows / t.leaf_blocks
		and avg_row_len
	,	case when nvl(t.leaf_blocks,1) /nvl(t.num_rows,1) = 1
		then 0
		else	nvl(t.leaf_blocks,1) /nvl(t.num_rows,1)
		end avg_rows_per_block
from dba_indexes t
join dba_tablespaces ts on ts.tablespace_name = t.tablespace_name
where t.table_owner = '&u_table_owner'
and t.table_name = '&u_table_to_check'
/

@tabidx '&u_table_owner' '&u_table_to_check'

