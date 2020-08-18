

col sqltempfile new_value sqltempfile noprint
var v_sqltempfile varchar2(200)

select'/tmp/sqlplus-settings-' || to_char(sys_context('userenv','sid')) || '-' || to_char(sys_context('userenv','sessionid')) || '.sql' sqltempfile from dual;

store set &sqltempfile replace

set feedback off pause off echo off  verify off
btitle off
ttitle off

exec :v_sqltempfile := '&sqltempfile'

@&sqltempfile





