
@@autotask_sql_setup

select
	window_name
	, start_time at time zone sessiontimezone start_time
	--, start_time
	, duration
from DBA_AUTOTASK_SCHEDULE
order by start_time

/
