
-- dfshrink-gen.sql


set pagesize 0
set linesize 200 trimspool on
set verify off

column cmd format a150 word_wrapped

with hwm as (
	select file_id, max(block_id+blocks-1) hwm
	from dba_extents
	group by file_id 
)
select 'alter database datafile '''||file_name||''' resize ' ||
		 ceil( ( nvl(hwm,1) * t.block_Size ) / power(2,20) )  || 'm;' cmd
from dba_data_files a, hwm, dba_tablespaces t
where a.file_id = hwm.file_id(+)
	and t.tablespace_name = a.tablespace_name
	and ceil( blocks * t.block_Size / power(2,20) ) 
		- ceil( ( nvl(hwm,1) * t.block_Size ) / power(2,20) ) > 0 
	-- 1 meg min size
	and ceil( ( nvl(hwm,1) * t.block_Size ) / power(2,20) ) > 1
	-- optional list of files by id
	--and a.file_id in (1,2,3...)
	-- optional list of tablespaces
	--and a.tablespace_name in ('USERS','DEMO'...)
/

