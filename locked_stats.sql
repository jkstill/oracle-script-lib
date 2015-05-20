
-- locked_stats.sql
-- show tables and indexes with locked statistics

@clears
set line 200 trimspool on
set pagesize 60

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

col table_name  format a30
col partition_name format a30
col subpartition_name format a30
col owner format a12

prompt
prompt #######################################
prompt ## Locked Stats Report
prompt ## Owner: &&v_stats_owner
prompt ## Table: &&v_stats_table
prompt #######################################
prompt

prompt
prompt #######################################
prompt ## table stats locked
prompt #######################################
prompt

select owner, table_name, partition_name, subpartition_name, last_analyzed, stattype_locked
from dba_tab_statistics
where owner = '&&v_stats_owner'
and table_name = '&&v_stats_table'
and stattype_locked is not null
order by 1,2,3
/

prompt
prompt #######################################
prompt ## index stats locked
prompt #######################################
prompt

select owner, index_name, partition_name, subpartition_name, last_analyzed, stattype_locked
from dba_ind_statistics
where owner = '&&v_stats_owner'
and table_name = '&&v_stats_table'
and stattype_locked is not null
order by 1,2,3
/
