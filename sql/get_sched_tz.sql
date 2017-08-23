
set serveroutput on size unlimited

var v_sched_timezone varchar2(30)

set feed off

declare
	v_tz varchar2(30);
begin
	dbms_scheduler.get_scheduler_attribute('default_timezone',v_tz);
	:v_sched_timezone := v_tz;
	dbms_output.put_line(v_tz);
end;
/

col v_sched_timezone noprint new_value v_sched_timezone

set echo off term off feed off
select :v_sched_timezone v_sched_timezone from dual;
set term on feed on

