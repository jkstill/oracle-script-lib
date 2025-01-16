--@ttitle.sql

col stime new_value start_time noprint
col instance_name new_value s_instance_name noprint

ttitle off
set feed off verify off

set term off
-- get db
select 'Instance: ' || instance_name instance_name from v$instance;
-- set the current time
select to_char(sysdate,'mm/dd/yyyy hh24:mi:ss') stime from dual;
set term on feed on

ttitle '&&1 report for ' skip '&s_instance_name' skip 'Date/Time:  &start_time' skip 2
