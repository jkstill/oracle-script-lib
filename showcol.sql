
-- showcol.sql
-- show column details and comments for a table
-- user the following command to prepare from import to Microsoft Word
-- grep -vE "^TABLE_NAME|^----------" col.txt | rtrim > column.txt

col table_name format a20
col col_name format a30
col comments format a70
col colformat format a15
set line 140 pause off feed on echo off pages 66 head on verify off

col u_table_name new_value u_table_name noprint
col u_table_owner new_value u_table_owner noprint

var v_table_name varchar2(30)
var v_table_owner varchar2(30)

prompt Owner of Table: 
set term off feed off
select '&&1' u_table_owner from dual;

set term on feed on
prompt Table Name:
set term off feed off
select '&&2' u_table_name from dual;

begin
	:v_table_name := upper('&&u_table_name');
	:v_table_owner := upper('&&u_table_owner');
end;
/

set term on feed on


break on table_name skip 1

select
	a.table_name,
	a.column_name,
	decode
	( a.data_type,
		'NUMBER', 
			decode( a.data_precision,
				 null,'NUMBER(38)',
				 a.data_type || '(' || to_char(data_precision) || ',' || to_char(data_scale) || ')' 
			) ,
		'VARCHAR2', a.data_type || '(' || to_char(data_length) || ')',
		'CHAR', a.data_type || '(' || to_char(data_length) || ')',
		'DATE', a.data_type,
		a.data_type
	) colformat ,
	b.comments
from dba_col_comments b, dba_tab_columns a
where
	a.owner like :v_table_owner
	and
	a.table_name like :v_table_name
	and
	a.column_name = b.column_name(+)
	and
	b.table_name = a.table_name
order by a.table_name, a.column_name
/


undef 1 2

