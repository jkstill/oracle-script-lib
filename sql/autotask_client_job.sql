
@@autotask_sql_setup

select 
	client_name
	, job_name
	, job_scheduler_status
	, task_name
	, task_target_type
	, task_target_name
	, task_priority
	, task_operation
from dba_autotask_client_job
--where client_name='auto optimizer stats collection'
order by 1
/
