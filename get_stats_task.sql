select
task_name
	, task_target_type
	, task_target_name
from dba_autotask_task
where client_name = 'auto optimizer stats collection'
/
