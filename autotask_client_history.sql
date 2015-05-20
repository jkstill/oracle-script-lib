
@@autotask_sql_setup

SELECT client_name
	, window_name
	, jobs_created
	, jobs_started
	, jobs_completed
	, window_start_time at time zone sessiontimezone window_start_time
	, window_end_time at time zone sessiontimezone window_end_time
FROM dba_autotask_client_history
--WHERE client_name like '%stats%'
order by client_name, window_end_time
/
