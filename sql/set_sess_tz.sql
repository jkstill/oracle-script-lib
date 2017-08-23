
@get_sched_tz
alter session set time_zone='&&v_sched_timezone';

select sessiontimezone from dual;

