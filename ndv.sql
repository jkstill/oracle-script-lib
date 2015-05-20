

@clears

col v_stats_owner new_value v_stats_owner noprint
col v_stats_table new_value v_stats_table noprint

prompt
prompt Table Owner:

set feed off term off
select upper('&1') v_stats_owner from dual;
set feed on term on

prompt
prompt Table Name:
prompt

set feed off term off
select upper('&2') v_stats_table from dual;
set feed on term on

col owner format a12
col table_name format a20
col partition_name format a20
col subpartition_name format a20
col column_name format a20
col ndv format 99,999,999
col sample_size format 99,999,999
col density format 99,999,999.90
col last_analyzed format a20

set linesize 200 trimspool on
set pagesize 60

prompt
prompt ###################################
prompt ## Owner: &&v_stats_owner
prompt ## Table: &&v_stats_table
prompt ###################################
prompt
prompt

prompt
prompt ###################################
prompt ## Table data
prompt ###################################
prompt

select
	table_name
	, column_name
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
	, num_distinct ndv
	, density
	, sample_size
from dba_tab_col_statistics
where owner = '&&v_stats_owner'
and table_name = '&&v_stats_table'
order by 1,2
/

prompt
prompt ###################################
prompt ## Partition data
prompt ###################################
prompt

select
	table_name
	, partition_name
	, column_name
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
	, num_distinct ndv
	, density
	, sample_size
from dba_part_col_statistics
where owner = '&&v_stats_owner'
and table_name = '&&v_stats_table'
order by 1,2
/

prompt
prompt ###################################
prompt ## SubPartition data
prompt ###################################
prompt

select
	table_name
	, subpartition_name
	, column_name
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
	, num_distinct ndv
	, density
	, sample_size
from dba_subpart_col_statistics
where owner = '&&v_stats_owner'
and table_name = '&&v_stats_table'
order by 1,2
/

undef 1 2

