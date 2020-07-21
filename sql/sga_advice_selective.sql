
-- gv$sga_target_advice
-- display if more than min_pct

set linesize 200 trimspool on
set pagesize 100

set verify off

def min_pct_gain=5

clear break
break on inst_id skip 1

set linesize 200 trimspool on
set pagesize 100

with data as (
	SELECT inst_id
		, con_id
		, sga_size
		, sga_size_factor
		, estd_db_time
		, estd_db_time_factor
		, estd_physical_reads
		, estd_buffer_cache_size
		, estd_shared_pool_size
	from gv$sga_target_advice
),
curr_sga as (
	 select d.*
	 from data d
	 -- change from 1 to previous value for testing
	 --where d.sga_size_factor = .5
	 where d.sga_size_factor = 1
),
max_sga as (
	select d.*
	from data d
	where (d.inst_id, d.sga_size_factor) in (
		select inst_id, max(sga_size_factor) sga_size_factor
		from data d
		group by inst_id
	)
),
selector as (
	 select c.inst_id
		  , c.con_id
		  , c.sga_size
		  , c.sga_size_factor
		  , m.estd_db_time
		  , c.estd_db_time_factor old_time_factor
		  , m.estd_db_time_factor new_time_factor
		  , (c.estd_db_time_factor - m.estd_db_time_factor) * 100 factor_saved_pct
	 from curr_sga c
		  , max_sga m
	 where c.inst_id = m.inst_id
		  and c.con_id = m.con_id
		  and (c.estd_db_time_factor - m.estd_db_time_factor ) * 100 > &min_pct_gain
)
select distinct
	 d.inst_id
	 , d.con_id
	 , d.sga_size
	 , d.sga_size_factor
	 , d.estd_db_time
	 , d.estd_db_time_factor old_time_factor
	 , d.estd_db_time_factor new_time_factor
	 , s.factor_saved_pct
from data d
	 join selector s on s.inst_id = d.inst_id
		  and s.con_id = d.con_id
		  --and d.shared_pool_size_factor in ( s.max_factor, s.shared_pool_size_factor )
order by d.inst_id, d.sga_size_factor
/

