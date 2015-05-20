
-- la8.sql
-- show last analyzed date for tables, indexes and columns
-- for a user

@clears
@columns

col table_owner format a30 head 'OWNER'
col index_owner format a30 head 'OWNER'
col monitoring format a3 head 'MON'

col ctabowner noprint new_value utabowner
prompt Table Owner:
set term off feed off
select upper('&1') ctabowner from dual;
set term on feed on

spool la8.txt

@title 'Table Analyzed Dates' 80

break on owner skip 1
col last_analyzed head 'DATE ANALYZED' format a20

select 
	t.owner
	, t.table_name
	, nvl(to_char(t.last_analyzed,'mm/dd/yyyy hh24:mi:ss'),'NOT ANALYZED') last_analyzed
	, monitoring
from dba_tables t
where t.owner like '&&utabowner%'
order by owner, table_name
/

@title 'Table Partition Analyzed Dates' 120

break on owner skip 1 on table_name

col partition_name format a30 head 'PARTITION NAME'
select 
	t.table_owner
	, t.table_name
	, t.partition_name
	, nvl(to_char(t.last_analyzed,'mm/dd/yyyy hh24:mi:ss'),'NOT ANALYZED') last_analyzed
from dba_tab_partitions t
where t.table_owner like '&&utabowner%'
order by table_owner, table_name
/

@title 'Index Analyzed Dates' 100

break on owner skip 1 on table_name

select 
	i.owner
	, i.table_name
	, i.index_name
	, nvl(to_char(i.last_analyzed,'mm/dd/yyyy hh24:mi:ss'),'NOT ANALYZED') last_analyzed
from dba_indexes i
where i.owner like '&&utabowner%'
order by owner, table_name, index_name
/

@title 'Index Partition Analyzed Dates' 140

break on owner skip 1 on table_name

select 
	i.index_owner
	, i.index_name
	, i.partition_name
	, nvl(to_char(i.last_analyzed,'mm/dd/yyyy hh24:mi:ss'),'NOT ANALYZED') last_analyzed
from dba_ind_partitions i
where i.index_owner like '&&utabowner%'
order by index_owner, index_name, partition_name
/

@title 'Column Analyzed Dates' 100

break on owner skip 1 on table_name

select 
	c.owner
	, c.table_name
	, c.column_name
	, to_char(c.last_analyzed,'mm/dd/yyyy hh24:mi:ss') last_analyzed
from dba_tab_columns c
where c.owner like '&&utabowner%'
and last_analyzed is not null
order by owner, table_name, column_name
/

spool off

undef 1
set newpage 1


