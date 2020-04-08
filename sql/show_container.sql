
-- show_container.sql
-- 12c - show current container

col container format a20
select sys_context ('userenv', 'con_name') container from dual;

show con_name


