
-- osstat-cpu-rpt.sql
-- generate a 'sar -u' like report from the database
-- Jared Still 2023
-- https://docs.oracle.com/en/database/oracle/oracle-database/21/refrn/V-OSSTAT.html#GUID-E1E48692-47FA-4AE3-9402-82477E66FFC0

set linesize 200 trimspool on
set pagesize 100
set term on feed on head on
set echo off tab off echo off verify off

col load format 990.0
col start_time format a20
col instance_number format 9999 head 'INST|NUM'

col num_cpus format 9999 head 'NUM|CPUS'
col user_time format a8 head 'USER|TIME'
col idle_time format a8 head 'IDLE|TIME'
col busy_time format a8 head 'BUSY|TIME'
col sys_time format a8 head 'SYS|TIME'
col iowait_time format a8 head 'IOWAIT|TIME'
col nice_time format a8 head 'NICE|TIME'

with function pct (value_in number, total_in number)
return varchar2
is
begin
	return to_char(value_in/total_in*100,'990.0') || '%';
end;
cpuraw as (
	select
		os.instance_number
		, os.snap_id
		, n.stat_name
		--, sn.startup_time
		, os.value
		,round(( (os.value - lag(os.value) over (partition by os.stat_id, os.instance_number order by os.snap_id))/100),0) curr_val
	from dba_hist_osstat os
	join dba_hist_snapshot sn on sn.snap_id = os.snap_id
		and sn.dbid = os.dbid
		and sn.instance_number = os.instance_number
	join dba_hist_osstat_name n on n.dbid = os.dbid
		and os.stat_id = n.stat_id
		and sn.instance_number = os.instance_number
	--where n.stat_name in ('LOAD','IDLE_TIME','BUSY_TIME','USER_TIME','SYS_TIME','IOWAIT_TIME','NICE_TIME')
	where n.stat_name in ('NUM_CPUS','LOAD','IDLE_TIME','USER_TIME','SYS_TIME','IOWAIT_TIME','NICE_TIME')
		and sn.begin_interval_time >= sysdate - 20
),
cpupivot as (
	select distinct instance_number, snap_id,
		sum(decode(stat_name,'LOAD',value,0)) LOAD,
		max(decode(stat_name,'NUM_CPUS',value,0)) NUM_CPUS,
		sum(decode(stat_name,'IDLE_TIME',curr_val,0)) IDLE_TIME,
		--sum(decode(stat_name,'BUSY_TIME',curr_val,0)) BUSY_TIME,
		sum(decode(stat_name,'USER_TIME',curr_val,0)) USER_TIME,
		sum(decode(stat_name,'SYS_TIME',curr_val,0)) SYS_TIME,
		sum(decode(stat_name,'IOWAIT_TIME',curr_val,0)) IOWAIT_TIME,
		sum(decode(stat_name,'NICE_TIME',curr_val,0)) NICE_TIME
	from cpuraw
	group by instance_number, snap_id
),
cpudata as (
	select 
		p.snap_id
		, p.instance_number
		, to_char(sn.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') start_time
		, p.load
		, p.num_cpus
		, p.user_time
		, p.idle_time
		--, p.busy_time
		, p.sys_time
		, p.iowait_time
		, p.nice_time
		-- busy_time is sys_time + user_time, so skip it - see doc link above
		, p.user_time + p.idle_time + p.sys_time + p.iowait_time + p.nice_time total_time
	from cpupivot p
	join dba_hist_snapshot sn 
		on sn.snap_id = p.snap_id
		and sn.instance_number = p.instance_number
	order by instance_number, snap_id
)
select 
	--snap_id
	start_time
	, instance_number
	, num_cpus
	, load
	, pct(user_time, total_time) user_time
	, pct(sys_time, total_time) sys_time
	, pct(idle_time, total_time) idle_time
	--, pct(busy_time, total_time) busy_time
	, pct(iowait_time, total_time) iowait_time
	, pct(nice_time, total_time) nice_time
	--, total_time
from cpudata
-- the first row of data per instance will have 0 due to lag() 
where total_time > 0
order by instance_number, snap_id
/


