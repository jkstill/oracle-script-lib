
-- sp_advice_selective.sql
-- display v$shared_pool_advice
-- shows results only when increasing SGA size predicts a benefit




set linesize 200 trimspool on
set pagesize 100

col shared_pool_size_for_estimate format 999999 heading "Size of Shared Pool in MB"
col shared_pool_size_factor format 99.90 head "Size Factor"
col estd_lc_time_saved format 99,999,999,999 head "Time Saved in sec"
col estd_lc_size format 99,999,999,999 head "Est libcache mem"
col estd_lc_memory_object_hits format 999,999,999,999 head 'libcache hits'

set verify off

def min_pct_gain=5

clear break
break on inst_id skip 1

set linesize 200 trimspool on
set pagesize 100

with data as (
	SELECT  inst_id
		, shared_pool_size_for_estimate
		, shared_pool_size_factor
		, estd_lc_size
		, estd_lc_time_saved
		, estd_lc_memory_object_hits
		, con_id
	FROM gv$shared_pool_advice
),
curr_sp as (
	select d.*
	from data d
	-- change from 1 to previous value for testing
	--where d.shared_pool_size_factor = .25
	where d.shared_pool_size_factor = 1
),
selector as (
	select
		f.con_id
		, f.inst_id
		, f.shared_pool_size_factor
		, f.max_factor
		, d.estd_lc_time_saved d_secs
		, f.estd_lc_time_saved f_secs
		, d.estd_lc_time_saved	- f.estd_lc_time_saved secs_gain
	from (
		select d.*
			, max(d.shared_pool_size_factor) over (partition by inst_id ) max_factor
		from data d
	) f
	join curr_sp c
	on c.inst_id = f.inst_id
		and c.shared_pool_size_factor = f.shared_pool_size_factor
		and c.con_id = f.con_id
	join data d on	 d.inst_id = f.inst_id
		and d.shared_pool_size_factor = f.max_factor
		and d.con_id = f.con_id
		--and d.estd_lc_time_saved > f.estd_lc_time_saved
		and (d.estd_lc_time_saved	- f.estd_lc_time_saved) / d.estd_lc_time_saved * 100 > &min_pct_gain
)
select distinct
	d.inst_id
	, d.shared_pool_size_for_estimate
	, d.shared_pool_size_factor
	, d.estd_lc_time_saved
	, s.secs_gain
	--, s.max_factor
	--, d.con_id
	--, s.*
from data d
	join selector s on s.inst_id = d.inst_id
		and s.con_id = d.con_id
		and d.shared_pool_size_factor in ( s.max_factor, s.shared_pool_size_factor )
order by d.inst_id, d.shared_pool_size_factor
/

