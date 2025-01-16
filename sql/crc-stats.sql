
-- crc-stats.sql
-- Client Result Cache Statistics

set linesize 200 trimspool on
set pagesize 100
col username format a20
col sid format 9999
col serial# format 999999
col name format a35 head 'RC Name'
col machine format a30
col osuser format a15

col block_count_current_value	 format 99999 head 'Block|Count|Current'
col block_count_max_value		 format 99999 head 'Block|Count|Max'
col block_size_value				 format 99999 head 'Block|Size'
col create_count_failure_value format 99999 head 'Create|Count|Failure'
col create_count_success_value format 99999 head 'Create|Count|Success'
col delete_count_invalid_value format 99999 head 'Delete|Count|Invalid'
col delete_count_valid_value	 format 99999 head 'Delete|Count|Valid'
col find_count_value				 format 9999999 head 'Find|Count'
col hash_bucket_count_value	 format 99999 head 'Hash|Bucket|Count'
col invalidation_count_value	 format 99999 head 'Invalidation|Count'


with rs as (
	select	*
	from (
		select cache_id, name, value from client_result_cache_stats$ 
	)
	pivot
	(
		--max(name) "NAME"
		max(value) "VALUE"
		for name in (
			'Block Count Current'	 block_count_current
			,'Block Count Max'		  block_count_max
			,'Block Size'				  block_size
			,'Create Count Failure'	  create_count_failure
			,'Create Count Success'	  create_count_success
			,'Delete Count Invalid'	  delete_count_invalid
			,'Delete Count Valid'	  delete_count_valid
			,'Find Count'				  find_count
			,'Hash Bucket Count'		  hash_bucket_count
			,'Invalidation Count'	  invalidation_count
		)
	)
)
select
	s.username
	, s.sid
	, s.serial#
	, s.machine
	, s.osuser
	, block_count_current_value
	, block_count_max_value
	, block_size_value
	, create_count_failure_value
	, create_count_success_value
	, delete_count_invalid_value
	, delete_count_valid_value
	, find_count_value
	, hash_bucket_count_value
	, invalidation_count_value
from gv$session_client_result_cache rc
	join rs on rs.cache_id = rc.cache_id
	join gv$session s on s.sid = rc.sid and s.serial# = rc.serial#
order by username, sid
/

