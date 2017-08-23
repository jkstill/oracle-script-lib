
@clears

col cuser noprint new_value uuser
col ctable noprint new_value utable

prompt Show tables for which owner:
set term off feed off
select upper('&&1') cuser from dual;
set term on feed on

prompt Which Table(s)? ( % wildcard allowed )
set term off feed off
select upper('&&2') ctable from dual;
set term on feed on

@title 'Tables For &uuser - Search Criteria &utable' 95

set pause off  verify off head on

col table_name format a30 head 'TABLE'
col column_name format a30 head 'COLUMN'
col data_type format a9 head 'TYPE'
col data_length format 99999 head 'LENGTH'
col data_precision format 99999999 head 'PRECISION'
col data_scall format 99999 head 'SCALE'
col nullable format a8 head 'NULLABLE'
col dlength format a10 head 'SIZE'

set line 95

break on table_name skip 1 


select 
	table_name, 
	column_name, 
	data_type, 
	decode(data_type,
		'NUMBER', decode( data_precision + data_scale, 
			NULL,NULL, 
			'(' || to_char(data_precision) || ',' || to_char(data_scale) || ')'
			),
		'DATE','',
		'(' || to_char(data_length) || ')'
	) dlength,
	decode(nullable,'Y','NULL','NOT NULL') nullable
from dba_tab_columns
where owner = upper('&uuser')
and table_name like upper('&utable')
order by table_name, column_name
/

undef 1 2

