
-- from performance tuning manual chapter 14

@@pgacols
clear break
-- tsize column is 

SELECT 
	to_number(decode(sid, 65535, null, sid)) sid
	, operation_type operation_type
	, trunc(expected_size/1024) expected_size_k
	, trunc(actual_mem_used/1024) actual_mem_used_k
	, trunc(max_mem_used/1024) max_mem_used_k
	, number_passes
	, trunc(tempseg_size/1024) tempseg_size
FROM V$SQL_WORKAREA_ACTIVE
ORDER BY 1,2
/

