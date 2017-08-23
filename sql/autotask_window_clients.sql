
@@autotask_sql_setup

select 
	window_name 
	, window_next_time at time zone sessiontimezone window_next_time
	, window_active   
	, autotask_status    
	, optimizer_stats     
	, segment_advisor      
	, sql_tune_advisor       
	, health_monitor   
from 
dba_autotask_window_clients
order by window_next_time
/

