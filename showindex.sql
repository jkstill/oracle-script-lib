-- showindex.sql
-- jkstill 2017-02-21 - remove tablespace - do not usually care about this
--         and it does not diplay for partitioned indexes
-- 
-- jkstill 2017-02-21 - widen tablename to 30


set line 200
set pagesize 100
set verify off

clear col
col indexname format a30 
col columnname format a35
col columnpos format 999 heading 'POS'
col tablespace_name format a20 head 'TABLESPACE'
col table_name format a30 head 'TABLE'

clear break
--break on table_name skip 1 on tablespace_name on indexname skip 1
break on table_name skip 1 on indexname skip 1
prompt 'table owner:'
col cowner noprint new_value uowner
set feed off term off
select '&1' cowner from dual;
set feed on term on

ttitle center 'Indexes for the &uowner'

select 
	a.table_name,
	a.index_name indexname,
	--a.tablespace_name,
	b.column_name columnname, 
	b.column_position columnpos
from dba_indexes a, dba_ind_columns b
where  a.table_name = b.table_name
	and a.index_name = b.index_name
	and a.owner = upper('&uowner') 
	and b.index_owner = upper('&uowner')
order by a.table_name,a.index_name, b.column_position
/

ttitle ' '
ttitle off



