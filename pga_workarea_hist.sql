
@@pgacols

clear break

set line 140

select
	low_optimal_size/1024 low_optimal_size_kb
	, (high_optimal_size+1)/1024 high_optimal_size_kb
	, optimal_executions
	, onepass_executions
	, multipasses_executions
	, total_executions
	, optimal_executions / total_executions * 100 pct_optimal_executions
	, onepass_executions / total_executions * 100 pct_onepass_executions
	, multipasses_executions / total_executions * 100 pct_multipasses_executions
	, ratio_to_report(optimal_executions) over ( ) * 100 pct_total_optimal_executions
from v$sql_workarea_histogram
where total_executions != 0
order by low_optimal_size_kb
/

