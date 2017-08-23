
@@logsetup sysaux_free

col bytes format 999,999,999,999 

set echo on

select sum(bytes) bytes from dba_free_space where tablespace_name = 'SYSAUX';

spool off


