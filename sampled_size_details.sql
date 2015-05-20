
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

set line 200
set pagesize 60
set trimspool on

col table_name format a10
col partition_name format a20 head 'PARTITION'
col subpartition_name format a20 head 'SUBPARTITION'
col num_rows format 99,999,999,999 head 'NUM ROWS'
col sample_size format  99,999,999,999 head 'SAMPLE SIZE'

clear break compute 
break on table_name on partition_name

select table_name, partition_name, subpartition_name, num_rows, sample_size
from dba_tab_statistics
where owner = '&&v_stats_owner'
and table_name = '&&v_stats_table'
order by table_name, partition_name, subpartition_name
/

clear break
break on index_name on partition_name

select index_name, partition_name, subpartition_name, num_rows, sample_size
from dba_ind_statistics
where owner = '&&v_stats_owner'
and table_name = '&&v_stats_table'
order by index_name, partition_name, subpartition_name
/

