

@clears
ttitle off
btitle off

col u_table_name new_value u_table_name noprint

prompt Root Table Name: [ROOT_DC|ROOT_NO_DC|sumpthin else]

set echo off feed off term off

select upper('&1') u_table_name from dual;
set term on feed on

prompt Table Name set to Table: '&u_table_name'


undef 1

