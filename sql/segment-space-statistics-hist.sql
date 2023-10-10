

-- segment-space-statistics-hist.sql
-- link to sssh.sql for ease of use
-- Jared Still 2023

/*

 get the current block changes per object
 this can be used to gauge the amount of redo per segment.

 oracle does not usually recreate full blocks in the redo. 

 the size of redo is dependent on just how much was changed in a block

*/

set linesize 200 trimspool on
set pagesize 100

col owner format a20
col object_name format a30 head 'OBJECT NAME'
col tbs_name format a30
col inst_id format 9999 head 'INST|ID'
col con_id format 999
col statistic_name format a30
col begin_interval_time format a19 head 'BEGIN TIME'
col db_block_changes_delta format 999,999,999 head 'BLOCK|CHANGES|DELTA'
col db_block_changes_total format 999,999,999 head 'BLOCK|CHANGES|TOTAL'

select
	sn.con_id 
	, sn.instance_number inst_id
	, to_char(cast(sn.begin_interval_time as date),'yyyy-mm-dd hh24:mi:ss')  begin_interval_time
	, obj.owner
	, obj.object_name
	--, obj.tablespace_name -- uncomment if needed
	, ss.db_block_changes_delta
	, ss.db_block_changes_total
from dba_hist_seg_stat_obj obj
join dba_hist_seg_stat ss on ss.con_id = obj.con_id
	and ss.dbid = obj.dbid
	and ss.obj# = obj.obj#
	and ss.dataobj# = obj.dataobj#
	and ss.ts# = obj.ts#
join dba_hist_snapshot sn on sn.snap_id = ss.snap_id
	and sn.dbid = ss.dbid
	and sn.instance_number = ss.instance_number
	and sn.con_id = ss.con_id
join dba_users u on u.username = obj.owner
	-- uncomment to see only application objects
	and u.oracle_maintained != 'Y'
order by con_id, inst_id, begin_interval_time, owner, object_name
/


