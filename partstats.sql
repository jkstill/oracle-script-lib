
-- partstats.sql
-- show basic statistics info for a table, partition and subpartitions
-- @partstats owner tablename

@clears

set linesize 200 pagesize 60

clear break

col v_owner new_value v_owner noprint
col v_tablename new_value v_tablename noprint
col partition_name format a15
col sub_partition_name format a15

prompt
prompt Table Owner:
set feed off term off
select upper('&1') v_owner from dual;

set term on
prompt
prompt Table name:
set term off feed off
select upper('&2') v_tablename from dual;
set term on feed on

@title 'Partition Stats' 120

select  table_name, global_stats, last_analyzed, num_rows
from dba_tables
where owner = '&&v_owner'
and table_name = '&&v_tablename'
order by 1, 2, 4 desc nulls last;

select  table_name, partition_name, global_stats, last_analyzed, num_rows
from dba_tab_partitions
where table_owner = '&&v_owner'
and table_name = '&&v_tablename'
order by 1, 2, 4 desc nulls last;

break on partition_name skip 1

select  table_name, partition_name, subpartition_name, global_stats, last_analyzed, num_rows
from dba_tab_subpartitions
where table_owner = '&&v_owner'
and table_name = '&&v_tablename'
order by 1, 2, 4 desc nulls last;

undef 1 2
