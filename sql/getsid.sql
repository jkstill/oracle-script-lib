
-- getsid.sql
-- get sid for current session

col sid format a12 head 'SID'

select sys_context('userenv','sid') sid from dual;

