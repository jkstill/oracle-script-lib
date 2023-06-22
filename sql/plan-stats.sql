-- plan-stats.sql
-- compare elapsed time per execution for each sql_id

set linesize 200 trimspool on
set pagesize 100


col start_time format a20 head 'START TIME'
col elapsed_time_sum format 99,990.099 head 'ELAPSED|TIME|SECONDS'
col PHYSICAL_READ_BYTES_SUM format 99,999,999,999,990 head 'PHYSICAL|READ|BYTES'
col smart_scan format 99,999,999,999,990 head 'SMART|SCAN|BYTES'
col buffer_gets_sum format 99,999,999,999,990 head 'BUFFER|GETS'
col day format a10
col sql_id format a13 head 'SQL ID'
col plan_count format 999999 head 'PLAN|COUNT'
col plan_hash_value format 999999999999 head 'PLAN|HASH|VALUE'

col elapsed_time_plan_min format 99,990.099 head 'ELAPSED|TIME|PLAN|MIN'
col elapsed_time_plan_max format 99,990.099 head 'ELAPSED|TIME|PLAN|MAX'
col elapsed_time_plan_avg format 99,990.099 head 'ELAPSED|TIME|PLAN|AVG'

col elapsed_time_min format 99,990.099 head 'ELAPSED|TIME|MIN'
col elapsed_time_max format 99,990.099 head 'ELAPSED|TIME|MAX'
col elapsed_time_avg format 99,990.099 head 'ELAPSED|TIME|AVG'

clear break

break on sql_id skip 1	on plan_count on plan_hash_value

spool plan-stats.log

set term off

with plans as (
	select /*+ no_merge */
		distinct sql_id, plan_hash_value, dbid
		, count(*) over (partition by	 sql_id, dbid) plan_count
		, count(*) plan_lines
	from dba_hist_sql_plan
	where dbid = (select dbid from v$database)
		and object_owner not in (
			select username from dba_users where ORACLE_MAINTAINED = 'Y'
		)
		and nvl(plan_hash_value,0) > 0
	group by sql_id, plan_hash_value, dbid
	--order by plan_hash_value
),
data as (
select
	p.sql_id
	, p.plan_count
	, s.plan_hash_value
	, to_char(t.begin_interval_time,'yyyy-mm-dd hh24:mi:ss')	 start_time
	, to_char(t.begin_interval_time,'Day') day
	, sum(s.elapsed_time_delta) / 1e6 elapsed_time_sum
	, sum(s.physical_read_bytes_total) physical_read_bytes_sum
	, sum(s.io_offload_return_bytes_delta) smart_scan
	, sum(s.buffer_gets_delta) buffer_gets_sum
from plans p
join dba_hist_sqlstat s on s.sql_id = p.sql_id
	and s.plan_hash_value = p.plan_hash_value
	and s.dbid = p.dbid
	and p.plan_count > 1
join dba_hist_snapshot t on t.snap_id = s.snap_id
	and t.instance_number = s.instance_number
group by p.sql_id, p.plan_count, s.plan_hash_value, begin_interval_time, to_char(t.begin_interval_time,'Day')
order by p.sql_id, s.plan_hash_value, begin_interval_time
)
select  distinct
	d.sql_id
	, d.plan_count
	, d.plan_hash_value
	, d.start_time
	, d.day
	, d.elapsed_time_sum
	, min(d.elapsed_time_sum) over (partition by d.sql_id, d.plan_hash_value) elapsed_time_plan_min
	, max(d.elapsed_time_sum) over (partition by d.sql_id, d.plan_hash_value) elapsed_time_plan_max
	, sum(d.elapsed_time_sum) over (partition by d.sql_id, d.plan_hash_value) / count(*) over (partition by d.sql_id, d.plan_hash_value)	elapsed_time_plan_avg
	, min(d.elapsed_time_sum) over (partition by d.sql_id) elapsed_time_min
	, max(d.elapsed_time_sum) over (partition by d.sql_id) elapsed_time_max
	, sum(d.elapsed_time_sum) over (partition by d.sql_id) / count(*) over (partition by d.sql_id)	 elapsed_time_avg
	, d.physical_read_bytes_sum
	--, d.smart_scan
	, d.buffer_gets_sum
from data d
where d.elapsed_time_sum > 0
/

spool off

set term on

ed plan-stats.log
