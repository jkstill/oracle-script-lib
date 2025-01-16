
@clears
ttitle off
btitle off

col schema_name new_value schema_name noprint

prompt Schema Name: [SOURCE|DEST]
prompt    Those are literal values BTW

set echo off feed off term off

select upper('&1') schema_name from dual;
set term on feed on

prompt Schema Name set to Schema: '&schema_name'


undef 1

