
@@autotask_sql_setup

select
	client_name
	, task_name
	, task_target_type
	, task_target_name
	, operation_name
	, attributes
	, status
	, deferred_window_name
	, current_job_name
	, job_scheduler_status
	, retry_count
	, last_good_date at time zone sessiontimezone last_good_date
	, next_try_date at time zone sessiontimezone next_try_date
	, last_try_date at time zone sessiontimezone last_try_date
	, last_try_result
from dba_autotask_task
order by client_name, task_name, last_try_date
/


