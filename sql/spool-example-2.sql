
-- spool.sql
-- Jared Still
-- template for spooling a logfile with timestamp



def log_prefix='logfile-name-here'

col file_timestamp new_value u_file_timestamp
select to_char(sysdate,'yyyy-mm-dd_hh24-mi-ss') file_timestamp from dual;

host mkdir -p logs

col logfile new_value u_logfile

select 'logs/&log_prefix-&u_file_timestamp..log' logfile from dual;


spool &u_logfile

select * from dual;

spool off

ed &u_logfile
