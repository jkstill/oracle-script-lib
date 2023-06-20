
/*

cpu-bucket-histogram.sql

histogram of CPU time 

call with instance number

example output

SQL# @cpu-bucket-histogram.sql 1

     CPU
     SEC        TIME
    USED    OcCURRED
-------- -----------
    0.00      11,485
    4.00         517
    3.00         270
    5.00         150
    1.00          54
    2.00          32

6 rows selected.


*/


clear break
btitle off
ttitle off
set echo off verify off pause off
set tab off

set feed off 
set pagesize 0
set linesize 300 trimspool on

col inst_id format 9999 head INST
col begin_time format a22
col total_cpu format 9990.09 head 'CPU|SEC|USED'
col cpu_seconds_avail format 999999 head 'CPU|SEC|AVAIL'
col cpu_consumed format 99990.09 head 'PCT|AVAIL|USED'
col time_count format 99,999,990 head 'TIME|OCCURRED'
col histogram format a100

col INSTANCE_TO_CHECK new_value INSTANCE_TO_CHECK noprint

prompt Which Instance:
set feed off term off
select '&1' INSTANCE_TO_CHECK from dual;
set feed on term on

set head on
set pagesize 50000
set feed on

with host_config as (
	-- this section may be an approximation
	-- as the values in dba_cpu_usage_statistics are infrequently sampled
	select
		dbs.timestamp
		, dbs.cpu_count
		, dbs.cpu_core_count
		,
		(
			case dbs.cpu_count / dbs.cpu_core_count -- cpu_count will be 2x cpu_core_count if hyperthreading is enabled
				when 2 then 1.2 -- convert to 1.2 CPUs for hyperthreading
			else 1
			end
		) * dbs.cpu_core_count / ( select count(*) from gv$instance)  cpu_per_host
	from dba_cpu_usage_statistics dbs
	where dbs.timestamp = ( select max(timestamp) from dba_cpu_usage_statistics)
),
rawdata as (
	select
		trunc(h.begin_time,'MI') begin_time
		, h.instance_number inst_id
		, n.metric_name || '.' || n.group_name metric_group_name
		, value / 100 seconds
	from dba_hist_sysmetric_history h
		, v$metricname n
	where	 n.group_id = h.group_id
		and n.metric_id = h.metric_id
		and (h.group_id, h.metric_id) in (
			select group_id, metric_id
			from v$metricname
			where upper(metric_name) like '%CPU%'
				and metric_unit = 'CentiSeconds Per Second'
		)
		and h.instance_number = &INSTANCE_TO_CHECK
	order by h.begin_time
),
metrics as (
	select
		d.begin_time
		--, d.metric_group_name
		, d.inst_id
		, nvl(sum(decode ( d.metric_group_name, 'Host CPU Usage Per Sec.System Metrics Long Duration', d.seconds)),0) host_cpu_long
		, nvl(sum(decode ( d.metric_group_name, 'Host CPU Usage Per Sec.System Metrics Short Duration', d.seconds)),0) host_cpu_short
		, nvl(sum(decode ( d.metric_group_name, 'CPU Usage Per Sec.PDB System Metrics Long Duration' , d.seconds)),0) db_pdb_long
		, nvl(sum(decode ( d.metric_group_name, 'CPU Usage Per Sec.System Metrics Long Duration', d.seconds)),0)	 db_long
		, nvl(sum(decode ( d.metric_group_name, 'Background CPU Usage Per Sec.PDB System Metrics Long Duration', d.seconds)),0)	 bg_db_pdb_long
		, nvl(sum(decode ( d.metric_group_name, 'Background CPU Usage Per Sec.System Metrics Long Duration', d.seconds)),0)	bg_db_long
	from rawdata d
	group by
		d.begin_time
		, d.inst_id
),
data as (
select
	m.inst_id,
	to_char(m.begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
	, m.host_cpu_long + m.db_pdb_long + m.db_long + m.bg_db_pdb_long + m.bg_db_long	total_cpu
	, hc.cpu_per_host cpu_seconds_avail
from metrics m
	, host_config hc
order by
	begin_time
	, inst_id
)
select
	--d.inst_id
	floor(d.total_cpu)  total_cpu
	, count(*) time_count
from data d
group by floor(d.total_cpu)
order by 2 desc
/






