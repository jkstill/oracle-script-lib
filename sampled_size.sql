

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

col table_name format a20
col index_name format a20
col partition_name format a20 head 'PARTITION'
col subpartition_name format a20 head 'SUBPARTITION'
col num_rows format 99,999,999,999 head 'NUM ROWS'
col sample_size format  99,999,999,999 head 'SAMPLE SIZE'
col object_type format a12

clear break compute
break on table_name on index_name

with tsum as (
	select table_name, num_rows, sample_size, count(*) ocount
	from dba_tab_statistics
	where owner = '&&v_stats_owner'
	and table_name = '&&v_stats_table'
	and object_type = 'TABLE'
	group by table_name, num_rows, sample_size
	order by table_name, num_rows, sample_size
),
tpsum as (
	select table_name, num_rows, sample_size, count(*) ocount
	from dba_tab_statistics
	where owner = '&&v_stats_owner'
	and table_name = '&&v_stats_table'
	and object_type = 'PARTITION'
	group by table_name, num_rows, sample_size
	order by table_name, num_rows, sample_size
),
tpssum as (
	select table_name, num_rows, sample_size, count(*) ocount
	from dba_tab_statistics
	where owner = '&&v_stats_owner'
	and table_name = '&&v_stats_table'
	and object_type = 'SUBPARTITION'
	group by table_name, num_rows, sample_size
	order by table_name, num_rows, sample_size
)
select table_name, 'TABLE' object_type, num_rows, sample_size, ocount
from tsum
union all
select table_name, 'PARTITION' object_type, num_rows, sample_size, ocount
from tpsum
union all
select table_name, 'SUBPARTITION' object_type, num_rows, sample_size, ocount
from tpssum
/


with isum as (
	select index_name, num_rows, sample_size, count(*) ocount
	from dba_ind_statistics
	where owner = '&&v_stats_owner'
	and table_name = '&&v_stats_table'
	and object_type = 'INDEX'
	group by index_name, num_rows, sample_size
	order by index_name, num_rows, sample_size
),
ipsum as (
	select index_name, num_rows, sample_size, count(*) ocount
	from dba_ind_statistics
	where owner = '&&v_stats_owner'
	and table_name = '&&v_stats_table'
	and object_type = 'PARTITION'
	group by index_name, num_rows, sample_size
	order by index_name, num_rows, sample_size
),
ipssum as (
	select index_name, num_rows, sample_size, count(*) ocount
	from dba_ind_statistics
	where owner = '&&v_stats_owner'
	and table_name = '&&v_stats_table'
	and object_type = 'SUBPARTITION'
	group by index_name, num_rows, sample_size
	order by index_name, num_rows, sample_size
)
select index_name, 'TABLE' object_type, num_rows, sample_size, ocount
from isum
union all
select index_name, 'PARTITION' object_type, num_rows, sample_size, ocount
from ipsum
union all
select index_name, 'SUBPARTITION' object_type, num_rows, sample_size, ocount
from ipssum
/



