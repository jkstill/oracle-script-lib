-- partstats_sum.sql
-- show basic statistics info for a table, partition and subpartitions
-- @partstats_sum owner tablename

@clears

col v_owner new_value v_owner noprint
col v_tablename new_value v_tablename noprint

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

col global_subpart_stats head 'GS|SUBPART' format a7
col global_part_stats head 'GS|PART' format a4
col global_stats head 'GS' format a4

@title 'Table/Partition Stats Summary' 80

set feed off

select  table_name, global_stats
from dba_tables
where owner = '&&v_owner'
and table_name = '&&v_tablename'
order by 1, 2;

ttitle off

select  table_name, global_stats global_part_stats, count(global_stats) gs_count
from dba_tab_partitions
where table_owner = '&&v_owner'
and table_name = '&&v_tablename'
group by table_name, global_stats
order by 1, 2;

ttitle off

select  table_name,	global_stats global_subpart_stats, count(global_stats) gs_count
from dba_tab_subpartitions
where table_owner = '&&v_owner'
and table_name = '&&v_tablename'
group by table_name, global_stats
order by 1, 2;

undef 1 2

set feed on
