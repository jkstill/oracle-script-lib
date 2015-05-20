
-- showkey.sql
-- find primary and unique keys,
-- and unique indexes for a table

@clears
@columns

col cowner noprint new_value uowner
col ctable noprint new_value utable

prompt Table Owner: 

set term off feed off
select upper('&1') cowner from dual;

set term on 
prompt Table Name: 
set term off
select upper('&2') ctable from dual;

set term on feed on

break on constraint_name skip 1 on constraint_type on status

prompt Primary and Unique keys for &&uowner..&&utable

select 
	ch.constraint_name
	, ch.constraint_type
	, ch.status
	, cd.column_name
from dba_constraints ch, dba_cons_columns cd
where ch.constraint_type in ('U','P')
	and ch.owner = '&&uowner'
	and ch.table_name = '&&utable'
	and cd.owner = ch.owner
	and cd.table_name = ch.table_name
	and cd.constraint_name = ch.constraint_name
order by constraint_name, position
/

prompt Unique indexes for &&uowner..&&utable

break on index_name skip 1 on status


select
	di.index_name
	, status
	, column_name
from dba_indexes di, dba_ind_columns dc
where di.uniqueness = 'UNIQUE'
	and di.owner = '&&uowner'
	and di.table_name = '&&utable'
	and dc.table_name = di.table_name
	and dc.index_name = di.index_name
	and dc.table_owner = di.owner
order by index_name, column_position
/


