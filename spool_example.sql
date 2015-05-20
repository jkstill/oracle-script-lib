
col udate new_value udate noprint

define logext='.log'

set echo off feed off
select to_char(sysdate,'yyyy-mm-dd_hh24-mi-ss') udate from dual;
set feed on

set feed on echo on pagesize 0 
-- trimspool for older versions - <= 9i I think
set linesize 200 trimspool on

spool spool_example_&udate.&logext

alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

select sysdate from dual;

spool off

set echo off pagesize 60

