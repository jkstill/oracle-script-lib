

-- hwm-df.sql
-- based on script from Connor McDonald
-- http://www.oracledba.co.uk/tips/file_hwm.htm

col file_name format a80
col hwm format 99,999,999,999
col total_blocks format 99,999,999,999
col shrinkage_blocks format 99,999,999,999
col shrinkage_bytes format 99,999,999,999,999
col block_size format 99999

set linesize 200 trimspool on
set pagesize 60

with data as (
	select a.file_name
		, b.hwm
		, a.blocks total_blocks
		, a.blocks-b.hwm+1 shrinkage_blocks
		, t.block_size
	from dba_data_files a,
	( 
		select file_id, max(block_id+blocks) hwm
		from dba_extents
		group by file_id 
	) b,
	dba_tablespaces t
	where a.file_id = b.file_id
	and t.tablespace_name = a.tablespace_name
)
select
	file_name
	, hwm
	, total_blocks
	, shrinkage_blocks
	, block_size
	, shrinkage_blocks * block_size shrinkage_bytes
from data
order by 4
/

