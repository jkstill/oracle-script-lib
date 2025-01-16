
-- block-summary.sql
-- summarize the block data in csv format
-- uses a timestamp as the first column

col u_timestamp new_value u_timestamp noprint
select to_char(sysdate,'yyyy-mm-dd_hh24-mi-ss') u_timestamp from dual;

set markup csv  on delimiter , quote off
set term off
set heading on headsep off feed off
set flush on
set linesize 1000 trimspool on
set pagesize 0

host mkdir -p csv
host mkdir csv

spool csv/block-summary-&u_timestamp..csv

with data as (
	select distinct
		e.owner
		, e.segment_name
		, e.partition_name
		, e.segment_type
		, e.tablespace_name
		, t.block_size
		, sum(e.blocks) over (partition by e.owner, e.segment_name, e.partition_name, e.segment_type, e.tablespace_name) total_blocks
	from dba_extents e
	join dba_tablespaces t on t.tablespace_name = e.tablespace_name
)
select
	to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') snaptime
	, owner
	, segment_name
	, partition_name
	, segment_type
	, tablespace_name
	, block_size
	, total_blocks
from data;

spool off

set markup csv off
set term on
set pagesize 100
set linesize 200

prompt csv/block-summary-&u_timestamp..csv



