
-- pga_advice_hist.sql
-- examine v$pga_target_advice_histogram
-- use inline view with 'over/partition' to limit selection
-- to those estimates that do not include any multipass estimates
--
-- further restrict selection by showing only those that consume
-- <= NN% of total server memory

-- 8 gig
define _server_memory=8589934592
-- 4 gig
--define _server_memory=4294967296
-- 4 gig
--define _server_memory=2147483648
-- 1 gig
--define _server_memory=1073741824

--define _server_memory_factor=.25
define _server_memory_factor=.8

@@pgacols

clear break
set line 140
break on  pga_target_for_estimate skip 1 on  pga_target_factor

select 
	pga_target_for_estimate
	, pga_target_factor
	, low_optimal_size
	, high_optimal_size
	, estd_optimal_executions
	, estd_onepass_executions
	, estd_multipasses_executions
	, estd_total_executions
	, ignored_workareas_count
from v$pga_target_advice_histogram
where pga_target_for_estimate <= &&_server_memory_factor * &&_server_memory
and pga_target_for_estimate in (
	select  pga_target_for_estimate
	from (
		select 
			max(pga_target_for_estimate) over ( partition by pga_target_for_estimate) pga_target_for_estimate
			, sum(estd_multipasses_executions) over ( partition by pga_target_for_estimate) sum_estd_multipasses
		from v$pga_target_advice_histogram
	) a
	where sum_estd_multipasses < 1
	group by pga_target_for_estimate, sum_estd_multipasses
)
order by pga_target_for_estimate, low_optimal_size
/


