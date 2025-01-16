
-- jared still
-- jkstill@gmail.com
-- 
-- 2013-06-05

col client_name format a40
col job_start_time format a40
col job_duration format a20
col job_name format a30

select
	client_name
	, job_start_time
	, job_name
	, job_duration
from DBA_AUTOTASK_JOB_HISTORY
order by client_name, job_start_time
/

