

col v_tablename new_value v_tablename noprint
col v_owner new_value v_owner noprint

col table_name format a20 head 'TABLE NAME'
col index_name format a20 head 'INDEX NAME'
col index_rows format 9,999,999,999 head 'INDEX ROWS'
col table_rows format 9,999,999,999 head 'TABLE ROWS'
col clustering_factor format 9,999,999,999 head 'CLUSTERING|FACTOR'
col leaf_blocks format 99,999,999 head 'LEAF|BLOCKS'
col table_blocks format 99,999,999 head 'TABLE|BLOCKS'


prompt 
prompt Owner: 
prompt 

set term off feed off verify off
select upper('&1') v_owner from dual;
set term on feed on

prompt 
prompt Table: 
prompt 

set term off feed off verify off
select upper('&2') v_tablename from dual;
set term on feed on


select 
	t.table_name
	, t.num_rows table_rows
	, t.blocks table_blocks
	, i.index_name
	, t.num_rows index_rows
	, i.leaf_blocks
	, clustering_factor
from all_tables t
	join all_indexes i 
		on i.table_owner = t.owner
		and i.table_name = t.table_name
where t.owner = '&v_owner'
	and t.table_name = '&v_tablename'

/

undef 1 2

