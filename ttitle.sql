
col stime new_value start_time noprint
col global_name new_value dbname noprint

ttitle off
set feed off verify off 

set term off
-- get db
select 'Database: ' || substr(global_name,1,instr(global_name,'.')-1) global_name from global_name;
-- set the current time
select to_char(sysdate,'mm/dd/yyyy hh24:mi:ss') stime from dual;
set term on feed on

ttitle '&&1 report for ' skip '&dbname' skip 'Date/Time:  &start_time' skip 2


