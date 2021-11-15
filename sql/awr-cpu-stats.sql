
-- awr-cpu-stats.sql
-- show load over time
-- useful when sar is not available
-- Jared Still - jkstill@gmail.com 

col begin_interval_time format a30
col previous_time format a30

set linesize 200 trimspool on
set pagesize 60

-- snap! this is 10g 
-- rewrite with decode
-- could use pivot with 11g+ but probably not worth the trouble to rewrite

/*

The unaccounted_for time is probably OS CPU usage but at 
the moment I do not see a method to verify that.

sar was used to check empircally, but the numbers did not correlate
some of this could be reporting error by oracle

*/

@get_date_range

@clear_for_spool

col unaccounted_for_pct format 999.9 head 'UNACCOUNTED|FOR PCT'
col unaccounted_for format 99999999 head 'UNACCOUNTED|FOR'

spool awr-cpu-stats.csv

prompt begin_interval_time, instance_number, elapsed, total_time, unaccounted_for, unaccounted_for_pct, load, idle_time, user_time, iowait_time ,busy_time ,os_cpu_wait_time, rsrc_mgr_cpu_wait_time, sys_time


with data as (
select sn.begin_interval_time, sn.snap_id, sn.dbid, sn.instance_number,
	max(decode(oss.stat_name,'LOAD', round(value,2))) LOAD,
	max(decode(oss.stat_name,'IDLE_TIME', value)) IDLE_TIME,
	max(decode(oss.stat_name,'USER_TIME', value)) USER_TIME,
	max(decode(oss.stat_name,'BUSY_TIME', value)) BUSY_TIME,
	max(decode(oss.stat_name,'IOWAIT_TIME', value)) IOWAIT_TIME,
	max(decode(oss.stat_name,'OS_CPU_WAIT_TIME', value)) OS_CPU_WAIT_TIME,
	max(decode(oss.stat_name,'RSRC_MGR_CPU_WAIT_TIME', value)) RSRC_MGR_CPU_WAIT_TIME,
	max(decode(oss.stat_name,'SYS_TIME', value)) SYS_TIME
from dba_hist_snapshot sn
join dba_hist_osstat oss on oss.snap_id = sn.snap_id
	and oss.dbid = sn.dbid
	and oss.instance_number = sn.instance_number
	and sn.begin_interval_time 
		between to_date(:v_begin_date,'&d_date_format')
		and to_date(:v_end_date,'&d_date_format')
	and oss.stat_name in (
		'LOAD'
		,'IDLE_TIME'
		,'USER_TIME'
		,'BUSY_TIME'
		,'IOWAIT_TIME'
		,'OS_CPU_WAIT_TIME'
		,'RSRC_MGR_CPU_WAIT_TIME'
		,'SYS_TIME'
	)
	--and sn.instance_number = 1
--join dba_hist_osstat_name osn on osn.dbid = oss.dbid
	--and osn.stat_id = oss.stat_id
group by sn.begin_interval_time, sn.snap_id, sn.dbid, sn.instance_number
order by sn.snap_id, sn.instance_number
), 
times as (
select
	d.begin_interval_time
	, d.instance_number
	, 
		(
			(extract  ( hour   from d.begin_interval_time - lag(d.begin_interval_time) over ( partition by d.instance_number order by d.begin_interval_time) ) * 3600)
			+(extract ( minute from d.begin_interval_time - lag(d.begin_interval_time) over ( partition by d.instance_number order by d.begin_interval_time) ) * 60) 
			+(extract ( second from d.begin_interval_time - lag(d.begin_interval_time) over ( partition by d.instance_number order by d.begin_interval_time) ) ) 
		) * 100 * os.value -- CPU Cores
	elapsed
	, d.LOAD
	, d.IDLE_TIME - lag(d.idle_time) over ( partition by d.instance_number order by d.begin_interval_time ) idle_time
	, d.USER_TIME - lag(d.user_time) over ( partition by d.instance_number order by d.begin_interval_time ) user_time 
	, d.BUSY_TIME - lag(d.busy_time) over ( partition by d.instance_number order by d.begin_interval_time ) busy_time
	, d.IOWAIT_TIME - lag(d.iowait_Time) over ( partition by d.instance_number order by d.begin_interval_time ) iowait_time
	, nvl(d.OS_CPU_WAIT_TIME - lag(d.os_cpu_wait_time) over ( partition by d.instance_number order by d.begin_interval_time ),0) os_cpu_wait_time
	, nvl(d.RSRC_MGR_CPU_WAIT_TIME - lag(d.rsrc_mgr_cpu_wait_time) over ( partition by d.instance_number order by d.begin_interval_time ),0) rsrc_mgr_cpu_wait_time
	, d.SYS_TIME - lag(d.sys_time) over ( partition by d.instance_number order by d.begin_interval_time ) sys_time
from data d
join dba_hist_osstat os on os.snap_id = d.snap_id
	and os.dbid = d.dbid
	and os.instance_number = d.instance_number
	--and os.stat_name = 'NUM_CPU_CORES' -- this not available in 12.1 for some reason
	and os.stat_name = 'NUM_CPUS' -- this not available in 12.1 for some reason
order by d.snap_id, d.instance_number
)
select /* 
	begin_interval_time
	, instance_number
	, trunc(elapsed) elapsed
	,(idle_time+user_time+sys_time+iowait_time+busy_time) total_time
	, elapsed - (idle_time+user_time+sys_time+iowait_time+busy_time+rsrc_mgr_cpu_wait_time+os_cpu_wait_time) unaccounted_for
	, abs((trunc(elapsed) - (idle_time+user_time+sys_time+iowait_time+busy_time+rsrc_mgr_cpu_wait_time+os_cpu_wait_time)) / elapsed * 100 ) unaccounted_for_pct
	, load 
	,idle_time
	, user_time	 
	, iowait_time 
	, busy_time
	, os_cpu_wait_time 
	, rsrc_mgr_cpu_wait_time
	, sys_time
	*/
	--/*
	to_char(begin_interval_time,'yyyy-mm-dd hh24:mi:ss')
	||','|| to_char(instance_number)
	||','|| to_char(nvl(trunc(elapsed),0) )
	||','|| to_char(nvl((idle_time+user_time+sys_time+iowait_time+busy_time),0))
	||','|| to_char(nvl(trunc(elapsed) - (idle_time+user_time+sys_time+iowait_time) ,0))
	||','|| to_char(round(abs((trunc(elapsed) - (idle_time+user_time+sys_time+iowait_time+busy_time+rsrc_mgr_cpu_wait_time+os_cpu_wait_time)) / elapsed * 100 ),2))
	||','|| to_char(nvl(load,0 ))
	||','|| to_char(nvl(idle_time,0))
	||','|| to_char(nvl(user_time,0	))
	||','|| to_char(nvl(iowait_time,0 ))
	||','|| to_char(nvl(busy_time,0 ))
	||','|| to_char(nvl(os_cpu_wait_time,0 ))
	||','|| to_char(nvl(rsrc_mgr_cpu_wait_time,0))
	||','|| to_char(nvl(sys_time,0))
	--*/
from times
-- exlude first row as it is useless due to lag()
where elapsed is not null 
/

spool off

@clears

ed awr-cpu-stats.csv


