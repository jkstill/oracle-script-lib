
-- pga_advice_selective.sql
-- display v$pga_target_advice
-- shows results only when increasing PGA size predicts a benefit


@pgacols

set verify off

def min_pct_gain=1

clear break
break on inst_id skip 1

set linesize 200 trimspool on
set pagesize 100

with data as (
	select
		a.inst_id
		, a.pga_target_for_estimate
		, a.pga_target_factor
		, a.advice_status
		, a.bytes_processed
		, a.estd_time
		, a.estd_extra_bytes_rw
		, a.estd_pga_cache_hit_percentage
		, a.estd_overalloc_count
		, a.con_id
	from gv$pga_target_advice a
),
curr_pga as (
	select d.*
	from data d
	-- change from 1 to previous value for testing
	--where d.pga_target_factor = .25
	where d.pga_target_factor = 1
),
selector as (
	select
		f.con_id
		, f.inst_id
		, f.pga_target_factor
		, f.lag_factor
		, f.lead_factor
		, d.estd_pga_cache_hit_percentage d_pct
		, f.estd_pga_cache_hit_percentage f_pct
		, d.estd_pga_cache_hit_percentage  - f.estd_pga_cache_hit_percentage pct_gain
	from (
		select d.*
		, lead(d.pga_target_factor) over (partition by inst_id order by pga_target_factor) lead_factor
		, lag(d.pga_target_factor) over (partition by inst_id order by pga_target_factor) lag_factor
		from data d
	) f
	join curr_pga c
	on c.inst_id = f.inst_id
		and c.pga_target_factor = f.pga_target_factor
		and c.con_id = f.con_id
	join data d on	 d.inst_id = f.inst_id
		and d.pga_target_factor = f.lead_factor
		and d.con_id = f.con_id
		and  d.estd_pga_cache_hit_percentage	> f.estd_pga_cache_hit_percentage + &min_pct_gain
)
select distinct
	d.inst_id
	, d.pga_target_for_estimate
	, d.pga_target_factor
	--, s.pga_target_factor
	--, s.lag_factor
	--, s.lead_factor
	--, d.advice_status
	, d.bytes_processed
	, d.estd_time
	, d.estd_extra_bytes_rw
	, d.estd_pga_cache_hit_percentage
	, s.pct_gain
	--, d.estd_overalloc_count
	--, d.con_id
	--, s.*
from data d
	join selector s on s.inst_id = d.inst_id
		and s.con_id = d.con_id
		and d.pga_target_factor in ( s.lead_factor, s.pga_target_factor )
order by d.inst_id, d.pga_target_factor
/
