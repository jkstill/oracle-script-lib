
@@autotask_sql_setup


select window_name
	, enabled
	, next_start_date at time zone sessiontimezone next_start_date
	, active
	--, next_start_date
	, repeat_interval
	, duration
from dba_scheduler_windows
where enabled = 'TRUE'
order by next_start_date

/


