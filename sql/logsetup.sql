
-- logsetup.sql
-- called by other scripts for logfile setup

set term off feed off echo off

col v_loggedname new_value v_loggedname noprint

select '&1' v_loggedname from dual;

col v_logfile new_value v_logfile noprint

select 'logs/' || to_char(sysdate,'yyyy-mm-dd_hh24_mi_ss') || '_' || '&&v_loggedname' || '.log' v_logfile from dual;

set term on feed on

spool &&v_logfile

undef 1

