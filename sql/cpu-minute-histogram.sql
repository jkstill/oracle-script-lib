
/*

cpu-minute-histogram.sql

histogram of CPU time

call with instance number
GT 100% used means waiting on CPU

example output

                                  CPU       PCT
                                  SEC     AVAIL
 INST BEGIN_TIME                 USED      USED HISTOGRAM
----- ---------------------- -------- --------- ----------------------------------------------------------------------------------------------------
    2 2022-02-03 02:38:00        3.26     81.56 ***
    2 2022-02-03 02:39:00        4.51    112.81 ****
    2 2022-02-03 02:40:00        3.96     98.90 ***
    2 2022-02-03 02:41:00        3.98     99.41 ***
    2 2022-02-03 02:42:00        4.66    116.41 ****
    2 2022-02-03 02:43:00        3.03     75.65 ***
    2 2022-02-03 02:44:00        4.53    113.19 ****
    2 2022-02-03 02:45:00        4.64    116.10 ****
    2 2022-02-03 02:46:00        3.23     80.77 ***
    2 2022-02-03 02:47:00        4.57    114.21 ****
    2 2022-02-03 02:48:00        4.69    117.24 ****
    2 2022-02-03 02:49:00        3.21     80.19 ***
    2 2022-02-03 02:50:00        4.59    114.79 ****
    2 2022-02-03 02:51:00        4.41    110.15 ****
    2 2022-02-03 02:52:00        3.15     78.84 ***
    2 2022-02-03 02:53:00        4.67    116.64 ****
    2 2022-02-03 02:54:00        4.66    116.46 ****


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
col histogram format a100


col INSTANCE_TO_CHECK new_value INSTANCE_TO_CHECK noprint

prompt Which Instance:
set feed off term off 
select '&1' INSTANCE_TO_CHECK from dual;
set feed on term on 

set head on
set pagesize 50000

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
	d.inst_id
	, d.begin_time
	, d.total_cpu
	--, d.cpu_seconds_avail
	, d.total_cpu / d.cpu_seconds_avail * 100 cpu_consumed
	, rpad('*', case floor(d.total_cpu) when 0 then 1 else floor(d.total_cpu) end, '*' ) histogram
from data d
order by d.inst_id, d.begin_time
/



