
@@autotask_sql_setup

break on job_name skip 1
set line 170
set pagesize 500

select
   client_name
   , window_name
   , window_start_time at time zone sessiontimezone window_start_time
   , window_duration
   , job_name
   , job_status
   , job_start_time at time zone sessiontimezone job_start_time
	, job_duration
	, job_error
	, job_info
from dba_autotask_job_history
--where client_name like '%optimizer stats%'
order by window_start_time, client_name
/
