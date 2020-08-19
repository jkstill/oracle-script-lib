-- gv$sga_target_advice
-- display if more than min_pct

set linesize 200 trimspool on
set pagesize 100

set verify off

def min_pct_gain=5

@@legacy-exclude

clear break
break on inst_id skip 1

set linesize 200 trimspool on
set pagesize 100

col inst_id format 9999 head 'INST|ID'
col con_id format 999 head 'CON|ID'
col sga_size format 9,999,999,999 head 'SGA|Megabytes'
col old_sga_size format 9,999,999,999 head 'Old SGA|Megabytes'
col sga_size_factor format 90.0999 head 'SGA|Size|Factor'
col old_sga_size_factor format 90.0999 head 'Old SGA|Size|Factor'
col estd_db_time format 99,999,999 head 'EST|DB TIME'
col old_estd_db_time format 99,999,999 head 'Old EST|DB TIME'
col old_time_factor format 90.0999 head 'Old TIME|FACTOR'
col new_time_factor format 90.0999 head 'New TIME|FACTOR'
col estd_buffer_cache_size format 99,999,999 head 'EST|Buffer|Cache Meg'
col estd_shared_pool_size format 99,999,999 head 'EST|Shared|Pool Meg'
col factor_saved_pct format 90.99 head 'EST|Saved|Pct'

with data as (
	SELECT inst_id
		&legacy_db , con_id
		, sga_size
		, sga_size_factor
		, estd_db_time
		, estd_db_time_factor
		, estd_physical_reads
		&legacy_db , estd_buffer_cache_size
		&legacy_db , estd_shared_pool_size
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
min_reads as (
	select /*+ nomerge */
		inst_id
		, min(estd_physical_reads) estd_physical_reads
	from gv$sga_target_advice
	group by inst_id
),
opt_sga as (
	select
		a.inst_id
		&legacy_db , a.con_id
		, sga_size
		, sga_size_factor
		, estd_db_time
		, estd_db_time_factor
		, a.estd_physical_reads
		&legacy_db , estd_buffer_cache_size
		&legacy_db , estd_shared_pool_size
		, rank() over (partition by a.inst_id, a.estd_physical_reads order by a.sga_size_factor) opt_sga_rank
	from gv$sga_target_advice a
		, min_reads m
	where m.inst_id = a.inst_id
		and m.estd_physical_reads = a.estd_physical_reads
),
selector as (
	select c.inst_id
		&legacy_db , c.con_id
		, c.sga_size old_sga_size
		, m.sga_size new_sga_size
		, c.sga_size_factor old_sga_size_factor
		, m.sga_size_factor new_sga_size_factor
		, c.estd_db_time_factor old_estd_db_time_factor
		, m.estd_db_time_factor new_estd_db_time_factor
		, c.estd_db_time old_estd_db_time
		, m.estd_db_time new_estd_db_time
		, (c.estd_db_time_factor - m.estd_db_time_factor) * 100 factor_saved_pct
	from curr_sga c
		, opt_sga m
	where c.inst_id = m.inst_id
		&legacy_db and c.con_id = m.con_id
		and m.opt_sga_rank = 1
		and (c.estd_db_time_factor - m.estd_db_time_factor ) * 100 > &min_pct_gain
)
select distinct
	d.inst_id
	&legacy_db , d.con_id
	, s.old_sga_size
	, d.sga_size
	, s.old_sga_size_factor
	, d.sga_size_factor
	, s.old_estd_db_time
	, d.estd_db_time
	, s.old_estd_db_time_factor old_time_factor
	, d.estd_db_time_factor new_time_factor
	&legacy_db , estd_buffer_cache_size
	&legacy_db , estd_shared_pool_size
	, s.factor_saved_pct
from data d
	join selector s on s.inst_id = d.inst_id
		&legacy_db and s.con_id = d.con_id
		and s.new_sga_size_factor = d.sga_size_factor
		--and d.shared_pool_size_factor in ( s.max_factor, s.shared_pool_size_factor )
order by d.inst_id, d.sga_size_factor
/

