
-- all-init-trans.sql
-- Jared Still 2023
-- get the INI_TRANS values for all non-system segments

set linesize 200 trimspool on
set pagesize 100

col owner format a30 head 'Owner'
col segment_type format a7 head 'Segment|Type'
col ini_trans format 999 head 'ITL'
col ini_trans_count format 99,999 head 'ITL|Count'

break on owner skip 1 on segment_type

with data as (
	select owner, 'Table' segment_type,	 nvl(ini_trans,0) ini_trans
	from dba_tables
	union all
	select table_owner, 'TabPart' segment_type,	nvl(ini_trans,0) ini_trans
	from dba_tab_partitions
	union all
	select table_owner, 'TabSubPart' segment_type,	nvl(ini_trans,0) ini_trans
	from dba_tab_subpartitions
	union all
	select owner, 'Index' segment_type,	 nvl(ini_trans,0) ini_trans
	from dba_indexes
	union all
	select index_owner, 'IndPart' segment_type,	nvl(ini_trans,0) ini_trans
	from dba_ind_partitions
	union all
	select index_owner, 'IndSubPart' segment_type,	nvl(ini_trans,0) ini_trans
	from dba_ind_subpartitions
)
select owner, segment_type, ini_trans, count(*) ini_trans_count
from data d
join dba_users u on u.username = d.owner
	and u.oracle_maintained = 'N'
group by owner, segment_type, ini_trans
order by owner, segment_type, ini_trans
/

