
col snap_time								format a20						head 'SNAP TIME'
col sql_text 								format A80 wrap 
col name										format a40
col value									format 99,999,999,999,999.99
col program									format a20

col pga_used_mem							format 99,999,999,999		head 'PGA USED MEM'
col pga_alloc_mem							format 99,999,999,999		head 'PGA ALLOC MEM'
col pga_max_mem							format 99,999,999,999		head 'PGA MAX MEM'

col sum_pga_used_mem						format 99,999,999,999		head 'SUM PGA USED MEM'
col sum_pga_alloc_mem					format 99,999,999,999		head 'SUM PGA ALLOC MEM'
col sum_pga_max_mem						format 99,999,999,999		head 'SUM PGA MAX MEM'

col max_pga_used_mem						format 99,999,999,999      head 'MAX PGA USED MEM'
col max_pga_alloc_mem					format 99,999,999,999      head 'MAX PGA ALLOC MEM'
col max_pga_max_mem						format 99,999,999,999      head 'MAX PGA MAX MEM'

col pga_target_for_estimate 			format 999,999,999,999		head 'PGA TARGET|FOR EST'
col pga_target_factor 					format 999.99					head 'PGA TARGET|FACTOR'
col adv										format a6 					 	head 'ADVICE STATE'
col bytes_processed 						format 999,999,999,999		head 'BYTES PROCESSED'
col estd_extra_bytes_rw 				format 999,999,999,999		head 'ESTIMATED EXTRA|BYTES RW'
col estd_pga_cache_hit_percentage 	format 999.99					head 'ESTIMATED PGA|CACHE HIT %'
col estd_overalloc_count				format 999,999,999			head 'ESTIMATED OVER|ALLOC COUNT'

col low_optimal_size 					format 99,999,999,999,999	head 'LOW OPTIMAL SIZE'
col high_optimal_size 					format 99,999,999,999,999	head 'HIGH OPTIMAL SIZE'
col low_optimal_size_kb 				format 99,999,999,999		head 'LOW OPTIMAL|SIZE KB'
col high_optimal_size_kb				format 99,999,999,999		head 'HIGH OPTIMAL|SIZE KB'
col estd_optimal_executions 			format 999,999,999			head 'ESTIMATED|OPTIMAL|EXECUTIONS'
col estd_onepass_executions 			format 999,999,999			head 'ESTIMATED|ONEPASS|EXECUTIONS'
col estd_multipasses_executions 		format 999,999					head 'ESTIMATED|MULTIPASS|EXECUTIONS'
col estd_total_executions				format 999,999,999			head 'ESTIMATED|TOTAL|EXECUTIONS'
col ignored_workareas_count			format 999,999					head 'IGNORED|WORKAREAS|COUNT'

col optimal_executions					format 999,999,999			head 'OPTIMAL|EXECUTIONS'
col sum_optimal_executions				format 999,999,999			head 'SUM OPTIMAL|EXECUTIONS'
col pct_optimal_executions				format 999.99					head 'PCT|OPTIMAL|EXE'
col pct_total_optimal_executions		format 999.99					head 'PCT TOTAL|OPTIMAL|EXE'
col onepass_executions					format 999,999,999			head 'ONE PASS|EXECUTIONS'
col pct_onepass_executions				format 999,999,999			head 'PCT ONE PASS|EXECUTIONS'
col multipasses_executions				format 999,999,999			head 'MULTIPASSES|EXECUTIONS'
col pct_multipasses_executions		format 999,999,999			head 'PCT|MULTIPASSES|EXECUTIONS'
col total_executions						format 999,999,999			head 'TOTAL|EXECUTIONS'



