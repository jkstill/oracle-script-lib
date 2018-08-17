
col log_count format a100
col log_date format a19

set linesize 200
set pagesize 100

select 
	to_char(trunc(first_time),'yyyy-mm-dd hh24:mi:ss') log_date
	, rpad('*',count(*),'*') ||'('|| count(*) ||')' log_count
from v$log_history
group by to_char(trunc(first_time),'yyyy-mm-dd hh24:mi:ss')
order by 1
/
