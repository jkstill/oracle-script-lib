
set pause off term on head on verify off
set linesize 200 trimspool on
set pagesize 60

col owner format a20
col table_name format a30
col index_name format a30
col partition_name format a30
col subpartition_name format a30
col last_analyzed format a22


select owner
	, table_name
	, partition_name
	, subpartition_name
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
from dba_tab_statistics
where stale_stats = 'YES'
and last_analyzed < sysdate - 7 -- at least a week old
order by owner, last_analyzed desc
/


select owner
	, index_name
	, partition_name
	, subpartition_name
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
from dba_ind_statistics
where stale_stats = 'YES'
and last_analyzed < sysdate - 7 -- at least a week old
order by owner, last_analyzed desc
/
